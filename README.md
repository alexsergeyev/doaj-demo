### Requirements

You will need to install docker and docker-compose. For more information, please refer to the [official documentation](https://docs.docker.com/compose/install/).
This project uses devcontainer, so it will install all the dependencies for you when you open the project in VSCode.


### Atlas Search for local development

Atlas Search is NOT available with open source MongoDB. You will need to use MongoDB Atlas for this project. You can create a free tier cluster and use it for development or use new feature ATLAS-CLI to create a local cluster for development. https://www.mongodb.com/blog/post/introducing-local-development-experience-atlas-search-vector-search-atlas-cli

### Atlas CLI

We will use docker-compose to setup atlas for local development. You can find more information about atlas cli here: https://docs.atlas.mongodb.com/atlas-cli/

```yml
  mongo:
    image: mongodb/atlas
    privileged: true
    command: |
      /bin/bash -c "atlas deployments setup --type local --port 27778 --bindIpAll --username root --password root --force && tail -f /dev/null"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - 27778:27778
```

And export it as a ENV variable to application.

```yaml
  app:
    environment:
      - MONGO_URL=mongodb://root:root@mongo:27778/?directConnection=true
```

### Test Dataset

We will use DOAJ (open access journals) dataset for testing. You can download it from here: https://doaj.org/docs/public-data-dump/

This dataset contains ~20k documets with journal metadata. We will use it to test our search queries.

Restore the dataset to your local mongodb instance.

```bash
bin/restore
```

Create indexes by running the following command:

```bash
bin/console
```

```ruby
Search::V1.setup
Search::V2.setup
```


