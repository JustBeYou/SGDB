-- ex 10
with counting as (
    select member_id, title_id, copy_id, count(book_date) as cnt
    from rental
    group by member_id, title_id, copy_id
)
select m.first_name, m.last_name, t.title, c.copy_id, c.cnt
from counting c, member m, title t
where c.member_id = m.member_id and
    t.title_id = c.title_id;

-- ex 11
with counting as (
    select title_id, copy_id, count(*) as cnt
    from rental
    group by title_id, copy_id
),
mostRented as (
    select a.title_id, a.copy_id, a.cnt
    from counting a
    inner join (
        select title_id, max(cnt) as cnt
        from counting
        group by title_id
    ) b on a.title_id = b.title_id and a.cnt = b.cnt
)
select tc.title_id, m.copy_id, m.cnt, tc.status
from mostRented m, title_copy tc
where tc.title_id = m.title_id and tc.copy_id = m.copy_id;

-- ex 12
--- la a si b doar trebuie schimbata putin conditia/join-ul
--- solutia de mai jos ar trebui sa fie "generica"
with reportDays as (
    select trunc(sysdate, 'month')+rownum-1 as dt
    from dual connect by trunc(sysdate, 'month')+rownum-1 < last_day(sysdate)
)
select rd.dt, count(r.book_date)
from rental r right join reportDays rd
-- intrebare: de ce nu merge fara TO_CHAR ?
on TO_CHAR(r.book_date, 'ddmonyyyy') = TO_CHAR(rd.dt, 'ddmonyyyy')
group by rd.dt
order by rd.dt;