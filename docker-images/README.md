# GOAL
Make a docker container with CLI tools for cloud dev work.

# Approach

- Allow users to call scripts from ./bin/ in this project as if they were locally installed.
- Allow users to specify environment variables to different folders with configuration data

# Currently supported features

## AWS:

- commands:
  - ./bin/aws: aws CLI version 2.
    - https://aws.amazon.com/cli/
    - This can be edited to run CLI version 1
  - ./bin/aws-shell: aws-shell command
    - https://github.com/awslabs/aws-shell
    - There is also a managed service for aws-shell, here:
      - https://console.aws.amazon.com/cloudshell

