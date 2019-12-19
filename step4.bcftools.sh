## bcftools--call snp indel
将bam文件生成vcf文件
Generate VCF or BCF containing genotype likelihoods for one or multiple alignment (BAM or CRAM) files

bcftools mpileup mpileup.1.bam --fasta-ref mpileup.ref.fa >mpileup.vcf

call snp
bcftools call mpileup.vcf -c  -v -o variants.vcf

上下联用
bcftools mpileup mpileup.1.bam --fasta-ref mpileup.ref.fa | bcftools call -mv -o raw.vcf

bcftools也可以进行SNP calling。在之前的版本中，通常都是和samtools的mpileup命令结合使用, 命令如下

samtools mpileup -uf ref.fa aln.bam | bcftools view -bvcg - > var.raw.bcf

由于samtools和bcftools更新得都很快，只要有一个版本不对，采用上面的pipeline就会报错。为了减少版本不合适带来的问题，bcftools的开发团队将`mpileup`这个功能添加到了bcftools中。

在最新版的bcftools 中，只需要使用bcftools这一个工具就可以实现SNP calling， 用法如下

bcftools mpileup mpileup.1.bam --fasta-ref mpileup.ref.fa | bcftools call -mv -o raw.vcf

`--fasta-ref`参数指定参考序列的fasta文件，`mpileup.bam`是输入文件，通常都是GATK 标准预处理流程得到的bam文件。

需要注意的是`mpileup`命令虽然也会输出VCF格式的文件，但是并不直接进行snp calling。下面的命令可以生成VCF格式的文件

bcftools mpileup mpileup.1.bam --fasta-ref mpileup.ref.fa >mpileup.vcf

里面的每一条记录并不是一个SNP位点，而是染色体上每个碱基的比对情况的汇总。这种信息官方称之为genotype likelihoods。

`call`命令才是真正的执行SNP calling的程序，基本用法如下

bcftools call mpileup.vcf -c  -v -o variants.vcf

在进行SNP calling 时，必须选择一种算法，有两种calling算法可供选择，分别对应`-c`和`-m`参数。`-c`参数对应`consensus-caller`算法， `-m`参数对应`multiallelic-caller`算法，后者更适合多种allel和罕见变异的calling。

`-v`参数也是常用参数，作用是只输出变异位点的信息，如果一个位点不是snp/indel, 不会输出

综合使用：
samtools mpileup -g -t AD,ADF,ADR,DP,SP -f genome.fasta sample1.bam sample2.bam | bcftools call -vM > variants.vcf 


