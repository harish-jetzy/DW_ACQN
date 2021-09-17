create or replace Function         bizdaysbetween
   ( start_dt IN varchar2,
     end_dt IN varchar2 )
   RETURN Number
IS
    bizdays Number;

BEGIN
    WITH date_tab AS
    (SELECT TO_DATE (start_dt, 'mm-dd-yyyy') + LEVEL - 1 business_date
    FROM DUAL
    CONNECT BY LEVEL <=
                        TO_DATE (end_dt, 'mm-dd-yyyy')
                        - TO_DATE (start_dt, 'mm-dd-yyyy')
                        + 1)
,
business_date as
    (SELECT business_date
    FROM   date_tab
    WHERE  TO_CHAR (business_date, 'DY') NOT IN ('SAT', 'SUN')
    and  business_date not in (select HOLIDAY_DATE from ACQN_DW.ACDM_BAH_WRK_HOLDAY_VW where HOLIDAY_DATE is not null)
    )

SELECT count(*) into bizdays FROM business_date;

RETURN(bizdays);
END;

----------------------

create or replace Function         nextbizday
/* Vidya Aiyer - Nov 2019 */
   ( start_dt IN date,
     bizdays IN integer )
     RETURN Date
IS
    end_dt Date;

BEGIN

WITH date_tab AS
    (SELECT start_dt + LEVEL business_date
       FROM DUAL
    CONNECT BY LEVEL <= 7
  )
,

holiday as
(
select holiday_date from ACQN_DW.ACDM_BAH_WRK_HOLDAY_VW
where holiday_date between start_dt and start_dt +7
)
,

business_date as
    (SELECT business_date
    FROM   date_tab
    WHERE  TO_CHAR (business_date, 'DY') NOT IN ('SAT', 'SUN')
    and  business_date not in (select holiday_date from holiday)
     order by business_date
    )
,

next_biz as
    (select min(business_date) AS next_biz_day from business_date)

select next_biz_day into end_dt from next_biz;

    RETURN(end_dt);
END;
---------------------
create or replace Function         wrkdaysbetween
   ( start_dt IN varchar2,
     end_dt IN varchar2 )
   RETURN Number
IS
    wrkdays Number;

BEGIN
    WITH date_tab AS
    (SELECT TO_DATE (start_dt, 'mm-dd-yyyy') + LEVEL - 1 work_date
    FROM DUAL
    CONNECT BY LEVEL <=
                        TO_DATE (end_dt, 'mm-dd-yyyy')
                        - TO_DATE (start_dt, 'mm-dd-yyyy')
                        + 1)
,
work_date as
    (SELECT work_date
    FROM   date_tab
    WHERE  TO_CHAR (work_date, 'DY') NOT IN ('SAT', 'SUN')
    )

SELECT count(*) into wrkdays FROM work_date;

RETURN(wrkdays);
END;