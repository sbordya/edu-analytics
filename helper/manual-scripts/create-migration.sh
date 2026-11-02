# create table + inserts
docker exec -t bi-postgres-1  pg_dump -U admin -d metabase --inserts > helper/postgres/init/04_metabase_seed.sql

# create just inserts
docker exec -t bi-postgres-1  pg_dump -U admin -d metabase --data-only --inserts > helper/postgres/init/05_metabase_seed.sql

# only just inserts for some tables
docker exec -t bi-postgres-1 pg_dump -U admin -d metabase \
  --data-only \
  --inserts \
  -t core_user \
  -t database \
  -t collection \
  -t report_card \
  -t report_dashboard \
  -t report_dashboardcard \
  > helper/metabase/migrations/01_metabase_seed.sql

# create table + inserts + instruction to connect to DB
(echo "\connect metabase;" && docker exec -t bi-postgres-1 pg_dump -U admin -d metabase --inserts) > helper/postgres/init/04_metabase_seed.sql
