C======================================================================
C  USDFLD: Track peak temperature (Tmax) for irreversible degradation
C
C  STATEV(1) = Tmax (°C)
C  FIELD(1)  = Tmax (°C) to drive material tables with DEPENDENCIES=1
C
C  Key idea: during cooling, FIELD(1) stays at Tmax -> "no recovery"
C======================================================================
      SUBROUTINE USDFLD(FIELD,STATEV,PNEWDT,DIRECT,T,CELENT,
     1 TIME,DTIME,CMNAME,ORNAME,NFIELD,NSTATV,NOEL,NPT,
     2 LAYER,KSPT,KSTEP,KINC,NDI,NSHR,COORD,JMAC,JMATYP,
     3 MATLAYO,LACCFLA)

      INCLUDE 'ABA_PARAM.INC'

      CHARACTER*80 CMNAME, ORNAME
      DIMENSION FIELD(NFIELD), STATEV(NSTATV)
      DIMENSION DIRECT(3,3), T(3,3), TIME(2), COORD(*)
      DIMENSION JMAC(*), JMATYP(*), LACCFLA(*)

C----- GETVRM workspace
      DIMENSION ARRAY(15), JARRAY(15)
      CHARACTER*3 FLGRAY(15)
      INTEGER JRCD

C----- User parameters
      DOUBLE PRECISION TEMP_CUR, TMAX_OLD, TMAX_NEW
      DOUBLE PRECISION T_CAP, EPS_INIT

C----- Cap at last table point to avoid extrapolation in property tables
      T_CAP    = 1200.0D0
C----- Robust init threshold (STATEV starts at 0 typically)
      EPS_INIT = 1.0D-6

C----- Read current temperature at this material point (integration point)
      CALL GETVRM('TEMP', ARRAY, JARRAY, FLGRAY, JRCD,
     1            JMAC, JMATYP, MATLAYO, LACCFLA)

      IF (JRCD .NE. 0) THEN
C------- If failed to read TEMP, keep previous state (defensive)
        TEMP_CUR = STATEV(1)
      ELSE
        TEMP_CUR = ARRAY(1)
      ENDIF

C----- Initialize Tmax on first call / first increment
      TMAX_OLD = STATEV(1)
      IF (TMAX_OLD .LE. EPS_INIT) THEN
        TMAX_OLD = TEMP_CUR
      ENDIF

C----- Update Tmax (irreversible)
      IF (TEMP_CUR .GT. TMAX_OLD) THEN
        TMAX_NEW = TEMP_CUR
      ELSE
        TMAX_NEW = TMAX_OLD
      ENDIF

C----- Cap Tmax to avoid requesting material properties outside tables
      IF (TMAX_NEW .GT. T_CAP) THEN
        TMAX_NEW = T_CAP
      ENDIF

C----- Write back
      STATEV(1) = TMAX_NEW
      FIELD(1)  = TMAX_NEW

      RETURN
      END
