# caso queria ligar o banco, para executar com eclipse
 
# Executar Postgresql em docker - modo dev

```
docker volume create desafio_postgresql_data
```

```
docker run -d --name desafio-postgresql --restart unless-stopped -e POSTGRES_DB=desafio -e POSTGRES_USER=desafio -e POSTGRES_PASSWORD=desafio -p 5432:5432 -v desafio_postgresql_data:/var/lib/postgresql/data postgres:17-alpine
```

