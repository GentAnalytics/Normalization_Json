with group1 as (
    select 
        event_date_dt as date,
        session_key as session_key,
        user_key as user_key,
        avg((engagement_time_msec))/1000 as engagement_time_sec
    from {{ref('stg_ga4__events')}}
    group by 1,2,3
),

include_user_properties_market as (
    select
     group1.*,
     user_properties.polestar_market
     from group1
     {% if var('user_properties', false) %}
    -- If user properties have been assigned as variables, join them on the user_key
    left join {{ref('stg_ga4__user_properties')}} as user_properties using (user_key)
    {% endif %}
),
include_user_pseudo_ids as (
    select 
    user_pseudo.user_pseudo_id,
    include_user_properties_market.*,
    from include_user_properties_market
    left join {{ref('dim_ga4__sessions')}} as user_pseudo using (user_key)
),
include_engagement as (
    select
    include_user_pseudo_ids.*,
    session_identifyer.session_engaged as session_eng,
    from include_user_pseudo_ids
    left join {{ref('dim_ga4__sessions')}} as session_identifyer using (session_key)

)

     
select 
date,
polestar_market,
user_pseudo_id,
user_key,
session_key,
session_eng,
engagement_time_sec
 from include_engagement


 