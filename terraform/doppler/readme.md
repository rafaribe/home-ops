Quick oneliner to run on CLI

```sh
export $(sops -d .env) && tf plan
```
