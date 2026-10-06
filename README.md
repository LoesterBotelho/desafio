# Para executar tudo junto 

### antes de subir verificar se as portas estão livres e liberadas : 

| Protocolo |  Porta | Serviço        | Tecnologia      |
| --------- | -----: | -------------- | --------------- |
| TCP       | `8080` | Backend        | Spring Boot API |
| TCP       |   `80` | Frontend       | React + Nginx   |
| TCP       | `5432` | Banco de Dados | PostgreSQL      |


```
docker compose up -d --pull always
```

---

```
node : v24.21.0 LTS
Java : 25
Spring Boot : 4.1.1
React : ^18.3.1
```

---

```
https://nodejs.org/en/download
https://www.oracle.com/br/java/technologies/downloads/#jdk25-windows
https://maven.apache.org/download.cgi
https://gradle.org/releases/
```

