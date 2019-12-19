准备好bam文件和参考基因组文件

#基因组fasta文件还有.dict 和.fai 两个索引文件
ln -s ~/data_for_variants_calling/genome.fasta ./
samtools faidx genome.fasta 
java -jar /opt/biosoft/picard-tools-2.17.3/picard.jar CreateSequenceDictionary \
	R=genome.fasta O=genome.dict
#准备bam文件
java -jar /opt/biosoft/picard-tools-2.17.3/picard.jar AddOrReplaceReadGroups \
	I=~/bowtie2/V1.sam O=V1.bam SO=coordinate ID=V1 LB=V1 PL=Illumina PU=run SM=V1
java -jar /opt/biosoft/picard-tools-2.17.3/picard.jar AddOrReplaceReadGroups \
	I=~/bowtie2/V2.sam O=V2.bam SO=coordinate ID=V2 LB=V2 PL=Illumina PU=run SM=V2
samtools index V1.bam
samtools index V2.bam

准备好基因组fasta文件和bam文件（需要注意BAM文件需要@RG信息，若缺少该信息，则GATK程序会报错，可以使用Picard软件的 AddOrReplaceReadGroups 命令来添加@RG信息）及其索引后，则可以使用GATK的HaplotypeCaller命令进行SNP/InDel分析。

gatk HaplotypeCaller -R genome.fasta -I V1.bam -ERC GVCF -O V1.g.vcf \
	--genotyping-mode DISCOVERY --pcr-indel-model CONSERVATIVE --sample-ploidy 2 \
	--min-base-quality-score 10 --kmer-size 10 --kmer-size 25
gatk HaplotypeCaller -R genome.fasta -I V2.bam -ERC GVCF -O V2.g.vcf \
	--genotyping-mode DISCOVERY --pcr-indel-model CONSERVATIVE --sample-ploidy 2 \
	--min-base-quality-score 10 --kmer-size 10 --kmer-size 25
-R 输入参考基因组序列
-I 输入BAM文件a
-ERC 该参数有三个值
	NONE 程序可以输入多个BAM文件进行分析，并给出最终的VCF结果文件
	BP_RESOLUTION 程序仅能输入一个BAM文件进行分析，并给出gvcf格式的结果文件
	GVCF 程序仅能输入一个BAM文件进行分析，并给出gvcf格式的文件结果。gvcf结果中包含变异位点和非变异位点区块，且当该参数值是GVCF的时候，-o参数的后缀必须要为.g.vcf，否则会报错。此外若该参数的值设置为BP_RESOLUTION或者GVCF，则-stand_cll_conf参数的值会自动设置为0.而命令中的-stand_cll_conf参数值无效，不过可以再下一个命令GenotypeGVCFs中再手动设置该参数。
--genotyping_mode 指定基因分型的模式
					DISCOVERY 尽可能检测出所有可能的SNP/INDEL位点
					GENOTYPE_GIVEN_ALLELES 表示仅对--dbsnp参数输入的SNP/INDEL位点进行分析
--pcr-indel-model 程序正在尝试修正因PCR而得到的错误INDEL。CONSERVATIVE使用不严格的阈值保留更多的true positive 同时也允许更多的false positive.
--simple-ploidy 设置样品的染色体倍数。若是多个样品混合到一起后进行测序的数据，则该值要设置成=样品数目*物种的染色体倍型。
--min-base-quality-score  默认 10. 根据比对位点上的碱基进行variants calling的时候，用于计算最低碱基质量
--kmer-size 对variants位点进行组装的时候，所使用的Kmer大小。可以使用多个kmer进行组装。默认的设置为
--kmer-size 10 ，25

对多个分别使用HaplotypeCaller命令进行分析后得到的.g.vcf文件，然后通过GATK的CombineGVCFs命令将多个样品的.g.vcf文件整合到一起，得到一个文件.g.vcf文件。再使用GenotypeGVCFs命令鉴定varnats位点，计算得到的QUAL,Allele Count.Allele Number，Allele Frequency等信息。

gatk CombineGVCFs -R genome.fasta -O combined.g.vcf -V V1.g.vcf V2.g.vcf 
gatk GenotypeGVCFs -R genome.fasta -O variants.raw.vcf -V combined.g.vcf --sample-ploidy 2


最后使用GATK的VariantFiltration命令对variants结果进行hard filtering。理论上，更好的filtering方法是根据已有的准确的variants位点，通过机器学习的方法进行variant quality score recalibrantion(VQSR)。该方法使用的命令是VariantRecalibrator。适用于大样本数，大数据，不适合小样本，简化基因组测序和转录组测序。


gatk VariantFiltration -R genome.fasta -O variants.filter.vcf -V variants.raw.vcf \
--filter-name FilterQual --filter-expression "QUAL < 30.0" \
--filter-name FilterQD --filter-expression "QD < 30.0" \
--filter-name FilterMQ --filter-expression "MQ < 30.0" \
--filter-name FilterFS --filter-expression "FS < 30.0" \
--filter-name FilterMQRankSum --filter-expression "MQRankSum < 30.0" \
--filter-name FilterReadPosRankSum --filter-expression "ReadPosRankSum < 30.0" 

