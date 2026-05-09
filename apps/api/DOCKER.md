# NHIS API Docker

Run the local API stack from this directory:

```sh
docker compose up --build
```

The stack starts:

- `api`: Dart API on `http://localhost:8080`
- `database`: PostgreSQL on `localhost:5432`

Useful endpoints:

```sh
curl http://localhost:8080/health
```

Stop the stack:

```sh
docker compose down
```

Stop the stack and delete the local PostgreSQL volume:

```sh
docker compose down -v
```
