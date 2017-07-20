# Gene Prediction Workflow

A suggested workflow for predicting genes from the assembly of your favourite genome.

![SAGA Workflow](https://github.com/guyleonard/single_cell_workflow/blob/master/images/gene_prediction.png)

This really is just a suggestion and ths script is a little bit hard coded and messy - in need of a lot of update/reconfiguration if you want to use it.

## Install Dependencies

An [Ansible]() playbook to install the software:

You can call the playbook to install like this:

    ansible-playbook install_gene_prediction_dependencies.yaml --sudo -K -c local -i "localhost," --ask-vault-pass

There are also tags so you can install one or many components in a go:

    ansible-playbook install_gene_prediction_dependencies.yaml --sudo -K -c local -i "localhost," --ask-vault-pass --tags repbase,hmmer

### RepeatMasker Libraries
RepeatMasker libraries require the user to obtain a username and password for access to [Repbase](http://www.girinst.org/repbase/). You should do this now, and make sure you also update the download link in the repeatmasker.yaml - unfortunately RepBase do not seem to keep links to previous version live - I despair.

For ansible installation the password is stored in an ansible 'vault' file. This file is also password protected, so the RepeatMasker install will not work for any external users of this repo, therefore you will need to make your own vault, containing your own password
with this command:

    ansible-vault create repbase_password.yml

and add your password like so:
```yaml
    ---
    repbase_password: PASSWORD
```

Your username is in the repeatmasker.yaml taskbook.



### rmblast
rmblast won't currently download with Ansible 2.1.1.0 as there's something up with ftp downloads, so you will have to manually download it yourself and place it in the .source dir.!?

### trf
You have to click a ridiculous web form button to get an in-browser download. What is this the '90s? In the meantime, I will just distribute the file here. (╯°□°)╯︵ ┻━┻

### genemark
Yet another case of seriously outdated and pointless software download/license models. You have to fill in a web form, agree to a non-standard licence and then get given a temporary download location. $&\*! This bad, bad practice has got to stop. It is not 1996 anymore. Crikey.

### genemark
It has a 400 day licence. After that you need to get a new one. :|

## Other Dependencies
1. [pigz](http://zlib.net/pigz/) - Parallel GZIP
2. tee - GNU Core
3. time - *nix Core
