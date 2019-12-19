##install software when you to do variants detection
#install_GATK4
wget https://github.com/broadinstitute/gatk/releases/download/4.0.0.0/gatk-4.0.0.0.zip
unzip gatk-4.0.0.0.zip
echo 'PATH=$PATH:/home/liuyue/project/software/gatk-4.0.0.0' >> ~/.bashrc
source ~/.bashrc

#install_picard
wget https://github.com/broadinstitute/picard/releases/download/2.9.0/picard.jar -O ./picard-2.9.0.jar

#install_samtools
wget -c https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
tar jxf samtools-1.9.tar.bz2
cd samtools-1.9/
./configure
make -j 4
#make install
echo 'PATH=$PATH:/home/liuyue/project/software/samtools-1.9' >> ~/.bashrc
source ~/.bashrc

#install_bcftools
wget -c https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2
tar jxf bcftools-1.2.tar.bz2
cd bcftools-1.2
make -j 4
#make install
echo 'PATH=$PATH:/home/liuyue/project/software/bcftools-1.9' >> ~/.bashrc
source ~/.bashrc

#install_bwa
wget http://nchc.dl.sourceforge.net/project/bio-bwa/bwa-0.7.15.tar.bz2
tar jxf bwa-0.7.15.tar.bz2
make -j 4
echo 'PATH=$PATH:/home/liuyue/project/software/bwa-0.7.15' >> ~/.bashrc
source ~/.bashrc

#install_bowtie2
wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.3.4/bowtie2-2.3.4-linux-x86_64.zip
unzip bowtie2-2.3.4-linux-x86_64.zip
echo 'PATH=$PATH:/home/liuyue/project/software/bowtie2-2.3.4-linux-x86_64' >> ~/.bashrc
source ~/.bashrc
