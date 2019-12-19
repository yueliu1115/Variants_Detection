## 使用snpEff进行SNP/INDEL进行注释

# SnpEff使用方法

> SnpEff 软件通过基因组结构注释数据（GTF文件），对VCF文件中的SNP/InDel信息进行注释，即主要解释了SNP/InDel是否能够对编码蛋白基因造成影响。

最近在给课题组做一些突变体基因定位的工作（BSA混池测序），得到了最终的VCF文件，然后最终将得到的SNP/InDel注释出来。

#### 1.SnpEff的下载

普通下载（推荐）

#软件下载
wget https://downloads.sourceforge.net/project/snpeff/snpEff_latest_core.zip
#解压缩
unzip snpEff_latest_core.zip -d ~


conda下载

conda activate mutmap
conda install -y snpeff
#conda下载的话，需要自己寻找snpeff软件包的位置



#### 2.SnpEff使用

SnpEff软件的主要程序就是snpEff.jar，该软件需要Java运行程序。SnpEff使用最多的程序就是build和eff,build适用于数据库的构建，eff适用于对SNP/InDel进行注释。

##### 2.1构建SnpEff数据库

SnpEff软件的运行，首先需要基因组fasta序列信息和GTF注释信息，来构建数据库。

配置文件步骤如下：

1.在~/snpEff/目录中，创建一个文件夹：data
2.在~/snpEFF/data目录下，创建一个文件夹
	AT_10/
	在这个文件夹中，分别放置了GTF文件和基因组文件(固定名字)
	genes.gtf sequences.fa
3.编辑~/snpEff/snpEff.config文件
	在文件的最后一行添加信息：(注意名字的一致性)
	AT_10.genome: AT

构建数据库步骤如下：

java -jar ~/snpEff/snpEff.jar build -c ~/snpEff/snpEff.config -gtf22 -v AT_10

#参数说明
java -jar: Java环境下运行程序
-c snpEff.config配置文件路径
-gtf22 设置输入的基因组注释信息是gtf2.2格式
-gff3 设置输入基因组注释信息是gff3格式
-v 设置在程序运行过程中输出的日志信息
最后的AT_10参数 设置输入的基因组版本信息，和~/snpEff/snpEff.config配置文件中添加的信息一致

##### 2.2使用SnpEff进行注释

java -Xmx10G -jar ~/snpEff/snpEff.jar eff -c ~/snpEff/snpEff.config AT_10 positive.vcf > positive.snp.eff.vcf -csvStats positive.csv -stats positive.html

最终会产生四个文件	positive.snp.eff.vcf	positive.html		positive.csv	positive.genes.txt

可以在positive.snp.eff.vcf文件中，分析自己的后续基因位点了。





### SnpEff结果文件的解读

> 根据上一篇简书中SnpEff结果产生的4个文件进行解读

##### 第一个文件：positive.snp.eff.vcf

其实positive.snp.eff.vcf文件的格式就是普通的VCF格式，
前面的很大段落都含有##
其实也就是注释行，这些内容一般可以不看，直接跳过注释行，往下看。

可以看到positive.snp.eff.vcf可以分为11列


第一列：CHROM 发生突变的染色体ID。

第二列：POS：发生突变的染色体上的具体位置。

第三列：ID 可以在后面的注释信息中找到geneID。

第四列：REF 参考基因组上的碱基或者序列。

第五列：ALT 发生突变后的碱基或者序列。

第六列：QUAL 得分，Phred格式的数值。代表着此为点是纯和的概率。此值越大，概率越低，代表着此为点是变异位点的可能性越大。

第七列：FILTER 过滤情况 ：一般分析后的结果都为PASS，则表示该位点是变异位点。

第八列：INFO 变异位点的相关信息。

第九列：FORMAT 变异位点的格式：比如 GT:PL:ADF:ADR:AD:GP:GQ

第十列：SAMPLEs 各个样本的值，这些值对应着第9列的各个部分，不同部分之间的值使用冒号分隔。

而SnpEff结果文件中，在INFO这一列中，增添了一个字段，ANN

ANN=A|upstream_gene_variant|MODIFIER|AT1G69210|AT1G69210|transcript|AT1G69210.1|protein_coding||c.-3686C>T|||||3686|,A|upstream_gene_variant|MODIFIER|AT1G69210|AT1G69210|transcript|AT1G69210.2|protein_coding||c.-3686C>T|||||3686|,A|downstream_gene_variant|MODIFIER|SP1L2|AT1G69230|transcript|AT1G69230.1|protein_coding||c.*2799C>T|||||2509|,A|downstream_gene_variant|MODIFIER|MES15|AT1G69240|transcript|AT1G69240.1|protein_coding||c.*4371C>T|||||4138|,A|downstream_gene_variant|MODIFIER|SP1L2|AT1G69230|transcript|AT1G69230.2|protein_coding||c.*2799C>T|||||2568|,A|intron_variant|MODIFIER|SIK1|AT1G69220|transcript|AT1G69220.1|protein_coding|8/17|c.1323+52C>T||||||,A|intron_variant|MODIFIER|SIK1|AT1G69220|transcript|AT1G69220.2|protein_coding|8/17|c.1242+52C>T||||||

新增的字段由|进行间隔，并且这个字段中包含了突变位点的注释信息，因此非常重要。

**重点关注以下几点：**

Allele	ANN=A	说明了：突变后的碱基是A

Annotation	upstream_gene_variant 造成的基因上游的突变 or downstream_gene_variant 在成的基因下游的突变
Annotation_Impact	突变位点造成的影响：一般可以划分为四类 **HIGH，MODERATE，LOW，MODIFILER**	
一般突变位点造成HIGH最好，往后依次效果越低。

Gene_Name 基因名称

Gene_ID 基因ID

Feature_Type 想要分析的特征类型，transcript, motif, miRNA 等

Feature_ID 根据`Feature Type`指定的特征，给出对应的ID

Transcript_BioType 转录本类型, 通常采用Ensembl数据库的转录本类型
