# Install Dependencies

1. [Assembly Dependencies](https://github.com/guyleonard/single_cell_workflow/tree/master/install_dependencies#1-assembly-dependencies)
2. [Gene Prediction Dependencies](https://github.com/guyleonard/single_cell_workflow/tree/master/install_dependencies#2-gene-prediction-dependencies)

## 1. Assembly Dependencies
A bash script to install the required software:

1. [PEAR](http://sco.h-its.org/exelixis/web/software/pear/doc.html)
2. [Trim Galore!](http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/)
  1. [cutadapt](https://cutadapt.readthedocs.org/en/stable/)
  2. [FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
3. [SPAdes](http://bioinf.spbau.ru/en/spades)
4. [QUAST](http://bioinf.spbau.ru/quast)
5. Mapping
  1. [BWA](https://github.com/lh3/bwa)
  2. [Samtools](http://www.htslib.org/)
6. BLAST
  1. [BLAST+ executables](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download) - megablast
  2. [NCBI 'nt' database](ftp://ftp.ncbi.nlm.nih.gov/blast/db/) - nt.*.tar.gz
  3. [NCBI Taxonomy dump](ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/) - taxdump.tar.gz
7. [blobtools](https://github.com/DRL/blobtools)
8. CEGMA
  1. [geneid](http://genome.imim.es/software/geneid/)
  2. [genewise](http://www.ebi.ac.uk/~birney/wise2/)
  3. [hmmer](http://hmmer.org/)
  4. [BLAST+](http://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download).
9. BUSCO v1
  1. [Python 3.0](https://www.python.org/download/releases/3.0/)
  2. [hmmer](http://hmmer.org/)
  3. [BLAST+](http://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download)
  4. [Augustus 3.0](http://bioinf.uni-greifswald.de/augustus/)
  5. [EMBOSS](ftp://emboss.open-bio.org/pub/EMBOSS/)
10. [MultiQC](http://multiqc.info/)

## 2. Gene Prediction Dependencies
An [Ansible]() playbook to install the software:


You can call the playbook to install like this:

    ansible-playbook install_gene_prediction_dependencies.yaml --sudo -K -c local -i "localhost," --ask-vault-pass

There are also tags so you can install one or many components in a go:

    ansible-playbook install_gene_prediction_dependencies.yaml --sudo -K -c local -i "localhost," --ask-vault-pass --tags repbase,hmmer


I have used ansible to install the dependencies for this workflow. I have also included a method to download the repbase libraries using my password - however it is
encrypted within the playbook, so it won't work for you. You will have to create your own ansible vault with this format

Also, rmblast won't currently download with Ansible 2.1.1.0 as there's something up with ftp downloads, so you will have do download it yourself to the .source dir.!?

RepeatMasker libraries requires the user to obtain a username and password for access to [Repbase](http://www.girinst.org/repbase/), it is stored in an ansible 'vault' file.
This file is also password protected, so the RepeatMasker install will not work for user of this repo, you will need to make your own vault, containing your own password
with this command:

    ansible-vault create repbase_password.yml

and add your password like so:
```yaml
    ---
    repbase_password: PASSWORD
```

Your username is in the repeatmasker.yaml taskbook

## Other Dependencies
1. [pigz](http://zlib.net/pigz/) - Parallel GZIP
2. tee - GNU Core
3. time - *nix Core

