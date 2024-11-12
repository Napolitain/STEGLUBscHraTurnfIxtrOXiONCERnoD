# README

### Warning

I use Docker and Docker Compose for managing containers to be prod or near prod ready.
That being said, using Docker on MacOS and Windows will be TOO SLOW for the 1 million records.
If that's an issue, using baremetal will be the way to go, which means setting up the postgres database and rails app on the computer
with the right config.

### Running the project

It will run both Rails app, and Postgres containers, which will be seen by the Rails app

```bash
docker-compose up
```

Then we should be able to query on host at :
- http://localhost:3000/top_urls
- http://localhost:3000/top_referrers

### Running into project/app (rails app)

```bash
docker-compose run --rm --entrypoint "/bin/bash" -v $(pwd):/workspace app
```

This can be useful to run the rails container without the app (without installing rails on computer) to do some commands such as :
- `rails db:migrate`
- `rails db:seed`
- `rails db:reset`

### Running into project/db (postgres)

Once in the container, we can run psql to query the database

```bash
psql -h localhost -p 5432 -U user -d apple_assessment_development
```

Then we can check some rows with :

```sql
SELECT * FROM page_views;
```
