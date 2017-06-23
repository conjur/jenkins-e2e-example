# jenkins-e2e

An example of an end-to-end Conjur + Jenkins integration.
In this demo, Jenkins executors assume Conjur machine identity
by using Conjur's [Host Factory]() auto-enrollment system.

## Requirements

* A modern version of Docker (~17.03.1) and `docker-compose` (~1.11.2) installed.
* Access to the `registry.tld/conjur-appliance-cuke-master:4.9-stable` image.

## Usage

1. Start Conjur and Jenkins:

  ```sh-session
  $ docker-compose up -d
  ```

  - Conjur UI is now available on port `443`: https://localhost/ui:
  - Jenkins UI is now available on port `8080`: http://localhost:8080.

2. Load a Conjur policy for Jenkins:

  ```sh-session
  $ docker-compose exec conjur conjur policy load --as-group security_admin jenkins-policy.yml
  ```

  If prompted for authentication, use `admin:secret`.

  This is also the username/password for the Conjur UI.
  In the Conjur UI, you can now see the policy: https://localhost/ui/policies/jenkins/.

  Load some values for the two variables we defined in policy.
  It doesn't really matter what the values are for this example:

  ```sh-session
  $ docker-compose exec conjur conjur variable values add jenkins/aws/iam/users/jenkins-executor/access_key_id n8p9asdh89p
  Value added

  $ docker-compose exec conjur conjur variable values add jenkins/aws/iam/users/jenkins-executor/secret_access_key 46s31x2x4rsf
  Value added
  ```

3. Create a Jenkins job.

4. Launch a Jenkins executor.
