# jenkins-e2e

An example of an end-to-end Conjur + Jenkins integration.
In this example, a Jenkins master assumes Conjur machine identity
by using Conjur's [Host Factory](https://developer.conjur.net/reference/services/host_factory/) auto-enrollment system.

## Requirements

* A modern version of Docker (~17.03.1) and `docker-compose` (~1.11.2) installed.
* Access to the `registry.tld/conjur-appliance-cuke-master:4.9-stable` image.

## Usage

### Setup

#### (Mostly) Automated

```sh-session
$ ./e2e.sh
```

When prompted for Conjur authentication, use username `admin` and password `secret`.

Note: to tear down the enviroment, use this: `docker-compose down -v`.

## Walkthrough

Once the environment is ready:
- Jenkins (without Conjur) web UI is now available on port `8080`: http://localhost:8080.
- Jenkins (with Conjur) web UI is now available on port `8081`: http://localhost:8081.
- Conjur web UI is now available on port `443`: https://localhost/ui:

1. Log into Jenkins (without Conjur) and run the 'poc' job.

- http://localhost:8080/job/poc/

Notice that the secrets are hard-coded in the the build script
[fetch_secrets_without_conjur.sh](fetch_secrets_without_conjur.sh).
Also, the secrets are now in source control and there is no access log.
Credential rotation is also difficult, and manual.

2. Log into Jenkins (with Conjur) and run the 'poc' job.

- http://localhost:8081/job/poc/

Notice that the secrets are never stored in source control, but instead
retrieved from Conjur in the build script
[fetch_secrets_with_conjur.sh](fetch_secrets_with_conjur.sh). Once that
build script exits, the secrets are purged from the system automatically.

[Summon](https://github.com/conjurinc/summon) is one of many ways to retrieve secrets,
given Conjur identity.
Secrets can also be retrieved using the Conjur CLI, UI, API, or many
of our language-specific clients.

3. View the secret access logs in the Conjur web UI.

Log in with username: 'admin', password: 'secret'.

Secrets:
- https://localhost/ui/variables/aws%2Fusers%2Fjenkins%2Faccess_key_id/
- https://localhost/ui/variables/aws%2Fusers%2Fjenkins%2Fsecret_access_key/

Layer and Host:
- https://localhost/ui/rails/layers/jenkins%2Fmasters
- https://localhost/ui/hosts/jenkins%2Fmasters%2Fmaster01/

Policy:
- https://localhost/ui/rails/policies/jenkins

Audit info can also be retrieved using the Conjur CLI, UI, API, or many
of our language-specific clients.

---

Note that in both cases, the secrets are leaked to the Jenkins build log.
This is undesirable if you're shipping Jenkins logs to an aggregation service.
There are many ways to make sure secrets don't make it into Jenkins build logs.

---

### Setup (Manual)

1. Start Conjur and Jenkins.

    ```sh-session
    $ docker-compose up -d
    ```

2. Load a Conjur policy for Jenkins.

    ```sh-session
    $ docker-compose exec conjur conjur policy load --as-group security_admin policy.yml
    ```

    If prompted for authentication, use `admin:secret`.

    This is also the username/password for the Conjur UI.
    In the Conjur UI, you can now see the policy: https://localhost/ui/policies/jenkins/.

    Load some values for the two variables we defined in policy.
    It doesn't really matter what the values are for this example:

    ```sh-session
    $ docker-compose exec conjur conjur variable values add aws/users/jenkins/access_key_id n8p9asdh89p
    Value added

    $ docker-compose exec conjur conjur variable values add aws/users/jenkins/secret_access_key 46s31x2x4rsf
    Value added
    ```

3. Assign Conjur identity to the Jenkins master.

    First, copy the Conjur public SSL cert to the Jenkins master:

    ```sh-session
    $ docker copy "$(docker-compose ps -q conjur):/opt/conjur/etc/ssl/ca.pem" conjur.pem
    $ docker copy conjur.pem "$(docker-compose ps -q jenkins):/etc/conjur.pem"
    ```

    Now apply a Conjur identity to the Jenkins master:

    ```sh-session
    docker-compose exec --user root jenkins /src/identify.sh
    ```

... more steps, can fill out if needed.
