#!/bin/bash
# Guy Leonard MMXVI
# Number of processor cores
THREADS=8

# Dependency Checks
#command -v pigz >/dev/null 2>&1 || { echo "I require pigz but it's not installed.  Aborting." >&2; exit 1;}
#command -v blastn >/dev/null 2>&1 || { echo "I require BLASTn but it's not installed.  Aborting." >&2; exit 1;}
#command -v multiqc >/dev/null 2>&1 || { echo "I require MultiQC but it's not installed.  Aborting." >&2; exit 1;}



# Working Directory
WD=`pwd`
echo "Working Directory: $WD"
# Script Dir
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get dirnames for current Single Cell Library
# Locations of FASTQs = Sample_**_***/raw_illumina_reads/
for DIRS in $WD/*; do

  if [ -d ${DIRS} ]; then
    echo "Working in ${DIRS}"

  GENE_DIR=$DIRS/raw_illumina_reads/GENE_PREDS
  mkdir -p $GENE_DIR

  SAMPLE_NAME="$(basename $DIRS)"
  echo "Sample: $SAMPLE_NAME"

  ## CEGMA
  # Already run, files are in CEGMA
  CEGMA_DIR=$DIRS/raw_illumina_reads/CEGMA
  CEGMA_GFF=$CEGMA_DIR/cegma.cegma.gff 

  ## GENOME = scaffold
  GENOME=$DIRS/raw_illumina_reads/SPADES/overlapped_and_paired/scaffolds.fasta


  ## SNAP 1
  SNAP1_DIR=$GENE_DIR/SNAP1
  mkdir -p $SNAP1_DIR
  cd $SNAP1_DIR
  cegma2zff ${CEGMA_GFF} ${GENOME} | tee snap.log
  fathom genome.ann genome.dna -categorize 1000 | tee -a snap.log
  fathom -export 1000 -plus uni.ann uni.dna | tee -a snap.log
  forge export.ann export.dna | tee -a snap.log
  hmm-assembler.pl ${GENOME} . > cegma_snap.hmm | tee -a snap.log
  cd ../


  ## GeneMark
  GENEMARK_DIR=$GENE_DIR/GENEMARK
  mkdir -p $GENEMARK_DIR
  cd $GENEMARK_DIR
  # setting minimum gene prediction to lower than default 300 - just in case!
  # setting minimum contig to 1000bp as the 50Kbp is quite high for SAGs
  gmes_petap.pl --ES --cores 24 --min_gene_prediction 100 --min_contig 1000 --sequence ${GENOME} | tee genemark.log
  cd ../


  ## MAKER 1
  MAKER_DIR=$GENE_DIR/MAKER
  mkdir -p $MAKER_DIR
  cd $MAKER_DIR
  # Other Maker Option Files
  cp $SCRIPT_DIR/maker_opts/maker_bopts.ctl $MAKER_DIR
  cp $SCRIPT_DIR/maker_opts/maker_exe.ctl $MAKER_DIR

  # Maker Options
  echo "genome=${GENOME}" > $MAKER_DIR/maker_opts_1.ctl
  echo "organism_type=eukaryotic" >> $MAKER_DIR/maker_opts_1.ctl
  echo "model_org=all" >> $MAKER_DIR/maker_opts_1.ctl
  echo "softmask=1" >> $MAKER_DIR/maker_opts_1.ctl
  echo "snaphmm=$SNAP1_DIR/cegma_snap.hmm" >> $MAKER_DIR/maker_opts_1.ctl
  echo "gmhmm=$GENEMARK_DIR/output/gmhmm.mod" >> $MAKER_DIR/maker_opts_1.ctl
  echo "min_contig=100" >> $MAKER_DIR/maker_opts_1.ctl
  echo "keep_preds=1" >> $MAKER_DIR/maker_opts_1.ctl
  echo "cpus=24" >> $MAKER_DIR/maker_opts_1.ctl
  ln -s $MAKER_DIR/maker_opts_1.ctl $MAKER_DIR/maker_opts.ctl

  maker ${genome} -base run_1 | tee maker_run_1.log

  gff3_merge -d $MAKER_DIR/run_1.maker.output/run_1_master_datastore_index.log
  mv run_1.all.gff maker_run_1.all.gff
  MAKER_GFF=$MAKER_DIR/maker_run_1.all.gff
  cd ../

  ## SNAP 2
  SNAP2_DIR=$GENE_DIR/SNAP2
  mkdir -p $SNAP2_DIR
  cd $SNAP2_DIR

  maker2zff -n ${MAKER_GFF} | tee snap.log
  fathom genome.ann genome.dna -categorize 1000 | tee -a snap.log
  fathom -export 1000 -plus uni.ann uni.dna | tee -a snap.log
  forge export.ann export.dna | tee -a snap.log
  hmm-assembler.pl ${GENOME} . > maker_snap_2.hmm | tee -a snap.log
  SNAP_ZFF=$SNAP2_DIR/genome.ann
  cd ../


  ## AUGUSTUS
  AUGUSTUS_DIR=$GENE_DIR/AUGUSTUS
  mkdir -p $AUGUSTUS_DIR
  cd $AUGUSTUS_DIR
  zff2gff3.pl $SNAP_ZFF | perl -plne 's/\t(\S+)$/\t\.\t$1/' >snap2_genome.gff
  SNAP2_GENOME=$AUGUSTUS_DIR/snap2_genome.gff
  autoAug.pl --genome=$GENOME --species=$SAMPLE_NAME --trainingset=$SNAP2_GENOME --singleCPU --noutr -v --useexisting | tee autoAug.log
  cd ../

  ## MAKER 2
  cd $MAKER_DIR

  # Maker Options
  echo "genome=${GENOME}" > $MAKER_DIR/maker_opts_2.ctl
  echo "organism_type=eukaryotic" >> $MAKER_DIR/maker_opts_2.ctl
  echo "model_org=all" >> $MAKER_DIR/maker_opts_2.ctl
  echo "snaphmm=$SNAP2_DIR/maker_snap_2.hmm" >> $MAKER_DIR/maker_opts_2.ctl
  echo "gmhmm=$GENEMARK_DIR/output/gmhmm.mod" >> $MAKER_DIR/maker_opts_2.ctl
  echo "augustus_species=$SAMPLE_NAME" >> $MAKER_DIR/maker_opts_2.ctl
  #echo "rm_gff=$MAKER_DIR/maker_run_1.all.gff" >> $MAKER_DIR/maker_opts_2.ctl # previous maker run for repeat masks to save time
  echo "min_contig=50" >> $MAKER_DIR/maker_opts_2.ctl
  echo "pred_stats=1" >> $MAKER_DIR/maker_opts_2.ctl
  echo "min_protein=20" >> $MAKER_DIR/maker_opts_2.ctl
  echo "alt_splice=1" >> $MAKER_DIR/maker_opts_2.ctl
  echo "keep_preds=1" >> $MAKER_DIR/maker_opts_2.ctl
  echo "evaluate=1" >> $MAKER_DIR/maker_opts_2.ctl
  echo "cpus=24" >> $MAKER_DIR/maker_opts_2.ctl

  rm $MAKER_DIR/maker_opts.ctl
  ln -s $MAKER_DIR/maker_opts_2.ctl $MAKER_DIR/maker_opts.ctl

  maker ${genome} -base run_2 | tee maker_run_2.log

  ## Collate GFF3 + FASTA
  gff3_merge -d $MAKER_DIR/run_2.maker.output/run_2_master_datastore_index.log
  mv run_2.all.gff maker_run_2.all.gff

  fasta_merge -d $MAKER_DIR/run_2.maker.output/run_2_master_datastore_index.log

  cd ../

  fi
done
