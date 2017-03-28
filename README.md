# Gene Prediction Workflow

A suggested workflow for predicting genes from the assembly of your favourite genome.

![SAGA Workflow](https://github.com/guyleonard/single_cell_workflow/blob/master/images/gene_prediction.png)

## Install Dependencies

An [Ansible]() playbook to install the software:

You can call the playbook to install like this:

    ansible-playbook install_gene_prediction_dependencies.yaml --sudo -K -c local -i "localhost," --ask-vault-pass

There are also tags so you can install one or many components in a go:

    ansible-playbook install_gene_prediction_dependencies.yaml --sudo -K -c local -i "localhost," --ask-vault-pass --tags repbase,hmmer

I have used ansible to install the dependencies for this workflow. RepeatMasker libraries require the user to obtain a username and password for access to [Repbase](http://www.girinst.org/repbase/), it is stored in an ansible 'vault' file.
This file is also password protected, so the RepeatMasker install will not work for any user of this repo, you will need to make your own vault, containing your own password
with this command:

    ansible-vault create repbase_password.yml

and add your password like so:
```yaml
    ---
    repbase_password: PASSWORD
```

Your username is in the repeatmasker.yaml taskbook.

NB - rmblast won't currently download with Ansible 2.1.1.0 as there's something up with ftp downloads, so you will have to manually download it yourself and place it in the .source dir.!?

## Other Dependencies
1. [pigz](http://zlib.net/pigz/) - Parallel GZIP
2. tee - GNU Core
3. time - *nix Core
