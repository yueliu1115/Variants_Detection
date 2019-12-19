使用如下数据演示该流程：
对两个样品使用IIlumina Hiseq平台进行了基因组重测序得到了4个fastq文件
基因组fasta文件genome.fasta

准备数据

mkdir variants_calling
cd variants_calling
ln -s ~/data_for_variants_calling/V?.?.fastq ./
ln -s ~/data_for_variants_calling/genome.fasta ./



（1）首先，使用Trimmomatic对raw reads进行截断和过滤，得到clean data

mkdir data_preprocessing
cd data_preprocessing
java -jar /home/yhc-z4/software/Trimmomatic-0.36/trimmomatic-0.36.jar PE -threads 4 -phred33 \
../V1.1.fastq ../V1.2.fastq V1.1_trim.fastq V1.1.unpaired.fastq \
V1.2_trim.fastq V1.2.unpaired.fastq \
ILLUMINACLIP:/home/yhc-z4/software/Trimmomatic-0.36/adapters/TruSeq3-PE.fa:2:30:10 \
LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
java -jar /home/yhc-z4/software/Trimmomatic-0.36/trimmomatic-0.36.jar PE -threads 4 -phred33 \
../V2.1.fastq ../V2.2.fastq V2.1_trim.fastq V2.1.unpaired.fastq \
V2.2_trim.fastq V2.2.unpaired.fastq \
ILLUMINACLIP:/home/yhc-z4/software/Trimmomatic-0.36/adapters/TruSeq3-PE.fa:2:30:10 \
LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36


（2）使用Bowtie2设置不严格的阈值（默认阈值）将clean data 比对到参考基因组90

bowtie2-build ../genome.fasta genome
bowtie2 -p 4 -x genome -1 V1.1_trim.fastq -2 V1.2_trim.fastq -S V1.sam 2> V1.bowtoe2.log
bowtie2 -p 4 -x genome -1 V2.1_trim.fastq -2 V2.2_trim.fastq -S V2.sam 2> V2.bowtoe2.log
samtools sort -@ 4 -O BAM -o V1.bam V1.sam
samtools sort -@ 4 -O BAM -o V2.bam V2.sam



（3）使用Picard软件去除PCR重复

java -jar /opt/biosoft/picard-tools-2.17.3/picard.jar MarkDuplicates I=V1.bam \
	REMOVE_DUPLICATES=TRUE O=V1.rm.bam M=V1.metrics
java -jar /opt/biosoft/picard-tools-2.17.3/picard.jar MarkDuplicates I=V2.bam \
	REMOVE_DUPLICATES=TRUE O=V2.rm.bam M=V2.metrics



（4）将去除PCR重复的SAM/BAM文件转换得到fastq文件

```shell
java -jar /opt/biosoft/picard-tools-2.17.3/picard.jar SamToFastq I=V1.rm.bam \
	F=V1.rd.1.fastq F2=V1.rd.2.fastq
java -jar /opt/biosoft/picard-tools-2.17.3/picard.jar SamToFastq I=V2.rm.bam \
	F=V2.rd.1.fastq F2=V2.rd.2.fastq
```



（5）利用BLESS软件去除了PCR重复的数据进行reads修正

#BLESS需要高版本GCC
#可以重新激活小环境或者需要重新更新对应的bashrc
source ~/.bashrc.gcc
bless -read1 V1.rd.1.fastq -read2 V1.rd.2.fastq -kmerlength 21 -prefix V1
bless -read1 V2.rd.1.fastq -read2 V2.rd.2.fastq -kmerlength 21 -prefix V2



（6）使用Bowtie2设置较严格的阈值（设置较样额的--score-min 参数，例如设置该参数的值为L,-0.3,-0.3）将修正后的数据比对到参考基因组

bowtie2 -p 4 -x genome --score-min L,-0.3,-0.3 --rg SM:V1 --rg PL:ILLUMINA \
	-1 V1.1.corrected.fastq -2 V1.2.corrected.fastq -S V1.corr.sam 2> V1.corr.bowtie2.log
bowtie2 -p 4 -x genome --score-min L,-0.3,-0.3 --rg SM:V1 --rg PL:ILLUMINA \
	-1 V2.1.corrected.fastq -2 V2.2.corrected.fastq -S V2.corr.sam 2> V2.corr.bowtie2.log
samtools sort -@ 4 -O BAM -o V1.corr.bam V1.corr.sam
samtools sort -@ 4 -O BAM -o V2.corr.bam V2.corr.sam


（7）再次利用Picard软件去除PCR重复，得到最终的可以用于GATK的BAM文件

java -jar /opt/biosoft/picard-tools-2.17.3/picard.jar MarkDuplicates I=V1.corr.bam \
	REMOBE_DUPLICATRS=true O ../V1.bam M=V1.corr.metrics
java -jar /opt/biosoft/picard-tools-2.17.3/picard.jar MarkDuplicates I=V2.corr.bam \
	REMOBE_DUPLICATRS=true O ../V2.bam M=V2.corr.metrics
cd ..
ls

## 
