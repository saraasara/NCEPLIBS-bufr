C> @file
C> @brief Read one or more data values from an NCEP prepbufr file.
C>
C> @author J. Woollen @date 1994-01-06

C> Read one or more data values from the BUFR data
C> subset that is currently open within the NCEPLIBS-bufr internal arrays.
C>
C> This subroutine is specifically designed for use with NCEP prepbufr files,
C> which contain a third dimension of data events for every
C> reported data value at every replicated vertical level.  It is
C> similar to subroutine ufbin3(), except that ufbin3() is used
C> for NCEP prepfits files and has one extra argument containing
C> the maximum number of data events for any data value, whereas
C> this subroutine is used for NCEP prepbufr files and stores the
C> same information internally within a COMMON block.
C>
C> It is the user's responsibility to ensure that USR is dimensioned
C> sufficiently large enough to accommodate the number of data values
C> that are to be read from the data subset.  Note also
C> that USR is an array of real*8 values; therefore, any
C> character (i.e. CCITT IA5) value in the data subset will be
C> returned in real*8 format and must be converted back into character
C> format by the application program before it can be used as such.
C>
C> "Missing" values in USR are always denoted by a unique
C> placeholder value.  This placeholder value is initially set
C> to a default value of 10E10_8, but it can be reset to
C> any substitute value of the user's choice via a separate
C> call to subroutine setbmiss().  In any case, any
C> returned value in USR can be easily checked for equivalence to the
C> current placeholder value via a call to function ibfms(), and a
C> positive result means that the value for the corresponding mnemonic
C> was encoded as "missing" in BUFR (i.e. all bits set to 1) within the
C> original data subset.
C>
C> @param[in] LUNIT - integer: Fortran logical unit number for
C> NCEP prepbufr file.
C> @param[out] USR - real*8(*,*): Data values.
C> @param[in] I1 - integer: First dimension of USR as allocated
C> within the calling program.
C> @param[in] I2 - integer: Second dimension of USR as allocated
C> within the calling program.
C> @param[in] I3 - integer: Third dimension of USR as allocated
C> within the calling program.
C> @param[out] IRET - integer: Number of replications of STR that were
C> read from the data subset, corresponding to the second dimension of USR.
C> @param[in] STR - character*(*): String of blank-separated Table B
C> mnemonics in one-to-one correspondence with the number of data
C> values that will be read from the data subset within the first
C> dimension of USR (see [DX BUFR Tables](@ref dfbftab) for further
C> information about Table B mnemonics).
C>
C> @author J. Woollen @date 1994-01-06
      RECURSIVE SUBROUTINE UFBEVN(LUNIT,USR,I1,I2,I3,IRET,STR)

      USE MODV_IM8B
      USE MODV_BMISS

      USE MODA_USRINT
      USE MODA_MSGCWD

      COMMON /USRSTR/ NNOD,NCON,NODS(20),NODC(10),IVLS(10),KONS(10)
      COMMON /UFBN3C/ MAXEVN
      COMMON /QUIET / IPRT

      CHARACTER*(*) STR
      CHARACTER*128 ERRSTR
      DIMENSION     INVN(255)
      REAL*8        USR(I1,I2,I3)

C----------------------------------------------------------------------
C----------------------------------------------------------------------

C  CHECK FOR I8 INTEGERS
C  ---------------------

      IF(IM8B) THEN
         IM8B=.FALSE.

         CALL X84(LUNIT,MY_LUNIT,1)
         CALL X84(I1,MY_I1,1)
         CALL X84(I2,MY_I2,1)
         CALL X84(I3,MY_I3,1)
         CALL UFBEVN(MY_LUNIT,USR,MY_I1,MY_I2,MY_I3,IRET,STR)
         CALL X48(IRET,IRET,1)

         IM8B=.TRUE.
         RETURN
      ENDIF

      MAXEVN = 0
      IRET   = 0

C  CHECK THE FILE STATUS AND I-NODE
C  --------------------------------

      CALL STATUS(LUNIT,LUN,IL,IM)
      IF(IL.EQ.0) GOTO 900
      IF(IL.GT.0) GOTO 901
      IF(IM.EQ.0) GOTO 902
      IF(INODE(LUN).NE.INV(1,LUN)) GOTO 903

      IF(I1.LE.0) THEN
         IF(IPRT.GE.0) THEN
      CALL ERRWRT('+++++++++++++++++++++WARNING+++++++++++++++++++++++')
      ERRSTR = 'BUFRLIB: UFBEVN - 3rd ARG. (INPUT) IS .LE. 0, ' //
     .   'SO RETURN WITH 6th ARG. (IRET) = 0; 7th ARG. (STR) ='
      CALL ERRWRT(ERRSTR)
      CALL ERRWRT(STR)
      CALL ERRWRT('+++++++++++++++++++++WARNING+++++++++++++++++++++++')
      CALL ERRWRT(' ')
         ENDIF
         GOTO 100
      ELSEIF(I2.LE.0) THEN
         IF(IPRT.GE.0) THEN
      CALL ERRWRT('+++++++++++++++++++++WARNING+++++++++++++++++++++++')
      ERRSTR = 'BUFRLIB: UFBEVN - 4th ARG. (INPUT) IS .LE. 0, ' //
     .   'SO RETURN WITH 6th ARG. (IRET) = 0; 7th ARG. (STR) ='
      CALL ERRWRT(ERRSTR)
      CALL ERRWRT(STR)
      CALL ERRWRT('+++++++++++++++++++++WARNING+++++++++++++++++++++++')
      CALL ERRWRT(' ')
         ENDIF
         GOTO 100
      ELSEIF(I3.LE.0) THEN
         IF(IPRT.GE.0) THEN
      CALL ERRWRT('+++++++++++++++++++++WARNING+++++++++++++++++++++++')
      ERRSTR = 'BUFRLIB: UFBEVN - 5th ARG. (INPUT) IS .LE. 0, ' //
     .   'SO RETURN WITH 6th ARG. (IRET) = 0; 7th ARG. (STR) ='
      CALL ERRWRT(ERRSTR)
      CALL ERRWRT(STR)
      CALL ERRWRT('+++++++++++++++++++++WARNING+++++++++++++++++++++++')
      CALL ERRWRT(' ')
         ENDIF
         GOTO 100
      ENDIF

C  PARSE OR RECALL THE INPUT STRING
C  --------------------------------

      CALL STRING(STR,LUN,I1,0)

C  INITIALIZE USR ARRAY
C  --------------------

      DO K=1,I3
      DO J=1,I2
      DO I=1,I1
      USR(I,J,K) = BMISS
      ENDDO
      ENDDO
      ENDDO

C  LOOP OVER COND WINDOWS
C  ----------------------

      INC1 = 1
      INC2 = 1

1     CALL CONWIN(LUN,INC1,INC2)
      IF(NNOD.EQ.0) THEN
         IRET = I2
         GOTO 100
      ELSEIF(INC1.EQ.0) THEN
         GOTO 100
      ELSE
         DO I=1,NNOD
         IF(NODS(I).GT.0) THEN
            INS2 = INC1
            CALL GETWIN(NODS(I),LUN,INS1,INS2)
            IF(INS1.EQ.0) GOTO 100
            GOTO 2
         ENDIF
         ENDDO
         INS1 = INC1
         INS2 = INC2
      ENDIF

C  READ PUSH DOWN STACK DATA INTO 3D ARRAYS
C  ----------------------------------------

2     IRET = IRET+1
      IF(IRET.LE.I2) THEN
         DO I=1,NNOD
         IF(NODS(I).GT.0) THEN
            NNVN = NVNWIN(NODS(I),LUN,INS1,INS2,INVN,I3)
            MAXEVN = MAX(NNVN,MAXEVN)
            DO N=1,NNVN
            USR(I,IRET,N) = VAL(INVN(N),LUN)
            ENDDO
         ENDIF
         ENDDO
      ENDIF

C  DECIDE WHAT TO DO NEXT
C  ----------------------

      CALL NXTWIN(LUN,INS1,INS2)
      IF(INS1.GT.0 .AND. INS1.LT.INC2) GOTO 2
      IF(NCON.GT.0) GOTO 1

      IF(IRET.EQ.0)  THEN
         IF(IPRT.GE.1)  THEN
      CALL ERRWRT('+++++++++++++++++++++WARNING+++++++++++++++++++++++')
      ERRSTR = 'BUFRLIB: UFBEVN - NO SPECIFIED VALUES READ IN, ' //
     .   'SO RETURN WITH 6th ARG. (IRET) = 0; 7th ARG. (STR) ='
      CALL ERRWRT(ERRSTR)
      CALL ERRWRT(STR)
      CALL ERRWRT('+++++++++++++++++++++WARNING+++++++++++++++++++++++')
      CALL ERRWRT(' ')
         ENDIF
      ENDIF

C  EXITS
C  -----

100   RETURN
900   CALL BORT('BUFRLIB: UFBEVN - INPUT BUFR FILE IS CLOSED, IT MUST'//
     . ' BE OPEN FOR INPUT')
901   CALL BORT('BUFRLIB: UFBEVN - INPUT BUFR FILE IS OPEN FOR OUTPUT'//
     . ', IT MUST BE OPEN FOR INPUT')
902   CALL BORT('BUFRLIB: UFBEVN - A MESSAGE MUST BE OPEN IN INPUT '//
     . 'BUFR FILE, NONE ARE')
903   CALL BORT('BUFRLIB: UFBEVN - LOCATION OF INTERNAL TABLE FOR '//
     . 'INPUT BUFR FILE DOES NOT AGREE WITH EXPECTED LOCATION IN '//
     . 'INTERNAL SUBSET ARRAY')
      END
