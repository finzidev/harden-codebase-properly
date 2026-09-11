/*PostgreSQL only. Run as `anon` and `authenticated`, never the owner:
  owners and bypassrls skip RLS. Null ACL = DEFAULT PRIVILEGES: execute to
  PUBLIC plus Supabase's grants to anon/authenticated, a P1 not a pass.
  Read every policy predicate: `true`, null, or no session function = a P1
  candidate. Another engine: the target-state item stands, not these queries.*/

select n.nspname, p.proname,
       coalesce(array_to_string(p.proacl, ' | '), 'DEFAULT: PUBLIC CAN EXECUTE') as acl
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' order by 2;

select c.relname, c.relrowsecurity, c.relforcerowsecurity
from pg_class c join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relkind in ('r','p') order by 1;

select t.tablename, pol.policyname, pol.cmd, pol.roles, pol.permissive,
       pol.qual, pol.with_check
from pg_tables t left join pg_policies pol
  on pol.schemaname = t.schemaname and pol.tablename = t.tablename
where t.schemaname = 'public' order by 1, 2;

/*no policy row + rowsecurity on = deny-all (correct); rowsecurity off =
  hole; `qual = true` = hole.*/
