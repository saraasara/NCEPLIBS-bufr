C> @file
C> @brief Initialize a DX BUFR tables message.
C>
C> ### Program History Log
C> Date | Programmer | Comments
C> -----|------------|----------
C> 1994-01-06 | J. Woollen | Original author.
C> 1997-07-29 | J. Woollen | Modified to update the current bufr version written in section 0 from 2 to 3.
C> 1998-07-08 | J. Woollen | Replaced call to cray library routine "abort" with call to new internal bufrlib routine bort().
C> 2000-09-19 | J. Woollen | Maximum message length increased from 10,000 to 20,000 bytes.
C> 2003-11-04 | S. Bender  | Added remarks/bufrlib routine interdependencies.
C> 2003-11-04 | D. Keyser  | Unified/portable for wrf; added documentation (including history); more diagnostic info.
C> 2004-08-09 | J. Ator    | Maximum message length increased from 20,000 to 50,000 bytes.
C> 2005-11-29 | J. Ator    | Changed default master table version to 12.
C> 2009-05-07 | J. Ator    | Changed default master table version to 13.
C> 2019-05-21 | J. Ator    | Changed default master table version to 29.
C> 2021-05-14 | J. Ator    | Changed default master table version to 36.
C>
C> @author Woollen @date 1994-01-06

C> This subroutine initializes a DX BUFR tables (dictionary)
C> message, writing all the preliminary information into Sections 0,
C> 1, 3, 4.  Subroutine wrdxtb() will write the
C> actual table information into the message.
C>
C> @note: Argument LUN is not referenced in this subroutine. It is left
C> here in case an application program calls this subroutine.
C>
C> @param[in] LUN - integer: I/O stream index into internal memory arrays.
C> @param[out] MBAY - integer: BUFR message.
C> @param[out] MBYT - integer: length (in bytes) of BUFR message.
C> @param[out] MB4 - integer: byte number in message of first byte in Section 4.
C> @param[out] MBA - integer: byte number in message of fourth byte in Section 4.
C> @param[out] MBB - integer: byte number in message of fifth byte in Section 4.
C> @param[out] MBD - integer: byte number in message of sixth byte in Section 4.
C>
C> @author Woollen @date 1994-01-06
      SUBROUTINE DXMINI(LUN,MBAY,MBYT,MB4,MBA,MBB,MBD)

      USE MODV_MXMSGL

      COMMON /DXTAB / MAXDX,IDXV,NXSTR(10),LDXA(10),LDXB(10),LDXD(10),
     .                LD30(10),DXSTR(10)

      CHARACTER*128 BORT_STR
      CHARACTER*56  DXSTR
      DIMENSION     MBAY(*)

C-----------------------------------------------------------------------
C-----------------------------------------------------------------------

c  .... The local message subtype is set to the version number of the
c       local tables (here = 1)
      MSBT = IDXV

C  INITIALIZE THE MESSAGE
C  ----------------------

      MBIT = 0
      DO I=1,MXMSGLD4
      MBAY(I) = 0
      ENDDO

C  For dictionary messages, the Section 1 date is simply zeroed out.
C  (Note that there is logic in function IDXMSG which relies on this!)

      IH   = 0
      ID   = 0
      IM   = 0
      IY   = 0

c  Dictionary messages get type 11 (see WMO Table A)
      MTYP = 11
      NSUB = 1

      IDXS = IDXV+1
      LDXS = NXSTR(IDXS)

      NBY0 = 8
      NBY1 = 18
      NBY2 = 0
      NBY3 = 7 + NXSTR(IDXS) + 1
      NBY4 = 7
      NBY5 = 4
      MBYT = NBY0+NBY1+NBY2+NBY3+NBY4+NBY5

      IF(MOD(NBY3,2).NE.0) GOTO 900

C  SECTION 0
C  ---------

      CALL PKC('BUFR' ,  4 , MBAY,MBIT)
      CALL PKB(  MBYT , 24 , MBAY,MBIT)
      CALL PKB(     3 ,  8 , MBAY,MBIT)

C  SECTION 1
C  ---------

      CALL PKB(  NBY1 , 24 , MBAY,MBIT)
      CALL PKB(     0 ,  8 , MBAY,MBIT)
      CALL PKB(     3 ,  8 , MBAY,MBIT)
      CALL PKB(     7 ,  8 , MBAY,MBIT)
      CALL PKB(     0 ,  8 , MBAY,MBIT)
      CALL PKB(     0 ,  8 , MBAY,MBIT)
      CALL PKB(  MTYP ,  8 , MBAY,MBIT)
      CALL PKB(  MSBT ,  8 , MBAY,MBIT)
      CALL PKB(    36 ,  8 , MBAY,MBIT)
      CALL PKB(  IDXV ,  8 , MBAY,MBIT)
      CALL PKB(    IY ,  8 , MBAY,MBIT)
      CALL PKB(    IM ,  8 , MBAY,MBIT)
      CALL PKB(    ID ,  8 , MBAY,MBIT)
      CALL PKB(    IH ,  8 , MBAY,MBIT)
      CALL PKB(     0 ,  8 , MBAY,MBIT)
      CALL PKB(     0 ,  8 , MBAY,MBIT)

C  SECTION 3
C  ---------

      CALL PKB(       NBY3 ,   24 , MBAY,MBIT)
      CALL PKB(          0 ,    8 , MBAY,MBIT)
      CALL PKB(          1 ,   16 , MBAY,MBIT)
      CALL PKB(       2**7 ,    8 , MBAY,MBIT)
      DO I=1,LDXS
      CALL PKB(IUPM(DXSTR(IDXS)(I:I),8),8,MBAY,MBIT)
      ENDDO
      CALL PKB(          0 ,    8 , MBAY,MBIT)

C  SECTION 4
C  ---------

      MB4 = MBIT/8+1
      CALL PKB(NBY4 , 24 , MBAY,MBIT)
      CALL PKB(   0 ,  8 , MBAY,MBIT)
      MBA = MBIT/8+1
      CALL PKB(   0 ,  8 , MBAY,MBIT)
      MBB = MBIT/8+1
      CALL PKB(   0 ,  8 , MBAY,MBIT)
      MBD = MBIT/8+1
      CALL PKB(   0 ,  8 , MBAY,MBIT)

      IF(MBIT/8+NBY5.NE.MBYT) GOTO 901

C  EXITS
C  -----

      RETURN
900   CALL BORT
     . ('BUFRLIB: DXMINI - LENGTH OF SECTION 3 IS NOT A MULTIPLE OF 2')
901   WRITE(BORT_STR,'("BUFRLIB: DXMINI - NUMBER OF BYTES STORED FOR '//
     . 'A MESSAGE (",I6,") IS NOT THE SAME AS FIRST CALCULATED, MBYT '//
     . '(",I6)') MBIT/8+NBY5,MBYT
      CALL BORT(BORT_STR)
      END
