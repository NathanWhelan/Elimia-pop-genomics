#This pipeline is for the processing of zipped illumina single end 75 bp files for AlfI 2b-RAD data.
#This pipeline was put together by Matt Galaska with the currently available skynet programs in mind. It has been modified by N. Whelan in December 2023 with some different scripts

###IT IS YOUR RESPONSIBILITY TO MAKE SURE SCRIPTS ARE IN YOUR PATH OR WORKING DIRECTORY
###This script requires BioPerl.
###This script requires GNU Parallel

#First, I suggest that you move all zipped files into a directory called /raw or other appropriate designation.
#This pipeline will unzip all files, truncate the files down to the AlfI contig size (minus a bp on either side where N's are more abundant).
#It will then discard any poor quality sequences and finally pull out only sequences containing the AlfI restriction site.
#Intermediate files are cleaned throughout the pipeline to keep directory size down as these are large files.

############################
##USES 10 cores by Default##
CORES=10  ##Can be changed##
############################

mkdir raw_backup
cp *.gz raw_backup/
rm Undetermined*.gz ##Removes file with reads that were not demultuiplexed correctly

#for FILENAME in *.gz
#        do
#        gunzip $FILENAME
#done

ls *.gz |parallel -j $CORES 'gunzip {}'

ls *.fq |parallel -j $CORES 'perl /usr/local/genome/bin/QualFilterFastq.pl -i {} -m 20 -x 5 -o {}.qual' ##Fix directory if necessary
rm -rf *.fq
rename .fq.qual .fastq *.fq.qual
cp *.qual raw_backup

ls *.fastq | parallel -j $CORES 'TruncateFastq.pl -i {} -s 1 -e 40 -o {}.trimmed'
cp *.trimmed raw_backup
rename .fastq.trimmed .fastq *.fastq.trimmed

ls *.fastq | parallel -j $CORES 'seqtk seq -a {} > {}.fasta'
cp *.fastq.fasta raw_backup
mv *.fastq raw_backup
rename .fastq.fasta .fasta *.fastq.fasta


ls *.fasta | parallel -j $CORES 'AlfIExtract.pl {} {}.alf.fasta'
cp *.fasta.alf.fasta raw_backup
rename .fasta.alf.fasta .fasta *.fasta.alf.fasta

