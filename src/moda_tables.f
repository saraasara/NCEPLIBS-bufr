# 1 "moda_tables.F"
	MODULE MODA_TABLES



	  USE MODV_MAXJL


	  INTEGER :: MAXTAB
	  INTEGER :: NTAB
# 25

	  CHARACTER*10 :: TAG(MAXJL)
	  CHARACTER*3 :: TYP(MAXJL)
	  INTEGER :: KNT(MAXJL)
	  INTEGER :: JUMP(MAXJL) 
	  INTEGER :: LINK(MAXJL)
	  INTEGER :: JMPB(MAXJL)
	  INTEGER :: IBT(MAXJL)
	  INTEGER :: IRF(MAXJL)
	  INTEGER :: ISC(MAXJL)
	  INTEGER :: ITP(MAXJL)
	  REAL*8 :: VALI(MAXJL)
	  INTEGER :: KNTI(MAXJL)
	  INTEGER :: ISEQ(MAXJL,2)
	  INTEGER :: JSEQ(MAXJL)


	END MODULE
