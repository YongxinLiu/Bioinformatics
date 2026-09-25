#!/usr/bin/env bash

# Linux 计算基础课堂练习脚本
# 建议从前往后逐段运行；不要一次性执行全文。
# 涉及 rm、mv、rename 的命令，先用 echo 或 printf 预览目标。

# 熟悉工作环境

# 查看文件列表
ls

# 显示当前工作目录 print working directory
pwd 

# cd 切换工作目录
cd 02Linux
pwd

# 编写一个shell程序 concatenate files and print on the standard output
cat <<END > test.sh
#!/usr/bin/env bash
echo 'Hello everyone!'
END


# 让文件变为程序 change file mode bits
chmod +x test.sh

# 运行程序
./test.sh


# 常用命令

# 显示当前文件夹文件 list directory contents
ls # ls是list的缩写
ls -l # 列表显示
ls -ltr # 按时间顺序倒序排列

# 新建文件夹 make directories 
mkdir -p test # 创建test目录

# 拷贝文件，原文件至目标位置
cp test.sh test/test.txt

# 进入文件夹
cd test

ls # 查看文件夹内容

# 切换至上级目录
cd ../ 

# 拷贝文件，原文件至目标位置：cp是copy的缩写
cp test.sh file_temp.txt # 复制文件
cp test.sh test/ # 复制文件到指定目录

# 移动或改名文件:mv是move的缩写
mv test.sh temp.sh # 移动，不更新目录为改名

# 拷贝文件，原文件至目标位置
rm test/test.sh # 文件
/bin/rm -r test # 删除文件夹


# 快捷键

# Tab键补全
# cat f # 单选时自动补全
# ls s # 多选时提示侯选

# 中止命令 Ctrl+C
ping  bic.ac.cn


# fastq文件操作

gzip example.fq
# 按列表显示文件详细
ls -lsh example.fq.gz

# 解压缩并保留原压缩文件
gzip -dk example.fq.gz

ls -lsh example.fq

# 显示文件前10行
head example.fq

# 一行内容太长，导致折行了，只提取前面 60 个字符展示
head example.fq | cut -c 1-60

# 按页查看文件,-S不换行，空格翻页，q退出
less -S example.fq

# 转换 FASTQ 为 FASTA，保留原 read ID
awk 'NR%4==1 {print ">" substr($0,2)} NR%4==2 {print}' example.fq > example.fa

# 显示fasta文件末尾10行
tail example.fa

# 查找某条序列motif
grep -F 'AAAACACAGGAACCTGGGTGAAAAC' example.fa | head

# 包含这个 motif 的序列有多少条
grep -F 'AAAACACAGGAACCTGGGTGAAAAC' example.fa | wc -l

# 模糊匹配
# <.>匹配任意字符
grep  'AAAACACAGGAACC.GGGTGAAAAC' example.fa | wc -l

# 匹配 A 或 T
grep  'AAAACACAGGAACC[AT]GGGTGAAAAC' example.fa | wc -l

grep  'AAAACACAGGAACCAGGGTGAAAAC' example.fa | wc -l

# 统计序列条数
grep -c '^>' example.fa

# 统计序列长度
grep -v '^>' example.fa | awk '{print length($0)}' | head

# 统计序列长度分布
grep -v '^>' example.fa | awk '{print length($0)}' | sort -n | uniq -c

# 清理临时文件
rm example.fa file_temp.txt temp.sh

# 压缩数据节约空间
gzip example.fq

# 生成一系列空文件
touch a_1.fq.gz a_2.fq.gz b_2.fq.gz b_1.fq.gz

# 查看生成的空文件
ls

# 重命名系列完整介绍 https://mp.weixin.qq.com/s/CtQdWfclesbXBVOIPtdzrw
# rename '被替换文字' '要替换成的文字' 操作对象
rename 'fq' 'fastq' *.fq.gz

# 不同操作系统，rename的使用方法略有不同。
# 在CentOS都是上面的语法 rename old new file_list
# 在Ubuntu都是下面的语法 rename s/old/new/ file_list
# rename 's/fq/fastq/' *.gz

# mac下的操作
# rename -s 'fq' 'fastq' *.gz

# 查看 rename 的用法
man rename
# NAME
#        rename - rename files
#
# SYNOPSIS
#        rename [options] expression replacement file...

# 复杂重命名但有时，需要重命名的文件不像上面那样有很清晰的模式，直接可以替换，
# 需要多几步处理获得对应关系。
# 假如已经有对应关系如下name.map.txt是自己手动编写的文件，
# a对应Control, b对应Treatment。

cat name.map.txt

# 一个比较笨的方式，一个个重命名
mv a_1.fastq.gz Control_1.fastq.gz
mv a_2.fastq.gz Control_2.fastq.gz
mv b_1.fastq.gz Treatment_1.fastq.gz
mv b_2.fastq.gz Treatment_2.fastq.gz

# 但如果有几百个样品呢？有没有办法生成上面这 4 行命令呢？
awk '{print $1"_1.fastq.gz", $2"_1.fastq.gz"; print $1"_2.fastq.gz", $2"_2.fastq.gz"}' name.map.txt

# 初步构建出来了，再加上命令 mv
awk '{print "mv -- "$1"_1.fastq.gz "$2"_1.fastq.gz"; print "mv -- "$1"_2.fastq.gz "$2"_2.fastq.gz"}' name.map.txt


# 可以直接拷贝上面的输出再粘贴运行，或存储为文件运行更方便，再重命名回去
awk '{print "mv -- "$2"_1.fastq.gz "$1"_1.fastq.gz"; print "mv -- "$2"_2.fastq.gz "$1"_2.fastq.gz"}' name.map.txt > rename.sh
bash rename.sh

# 也可以把print改为system直接运行
awk '{system("mv -- \""$1"_1.fastq.gz\" \""$2"_1.fastq.gz\""); system("mv -- \""$1"_2.fastq.gz\" \""$2"_2.fastq.gz\"")}' name.map.txt

# 再改回来
awk '{system("mv -- \""$2"_1.fastq.gz\" \""$1"_1.fastq.gz\""); system("mv -- \""$2"_2.fastq.gz\" \""$1"_2.fastq.gz\"")}' name.map.txt

# 用 rename 也可以
awk '{system("rename " $1 " " $2 " *.fastq.gz")}' name.map.txt

# 如果是 mac
awk '{system("rename -s " $1 " " $2 " *.fastq.gz")}' name.map.txt

# 查看下重命名后的文件
ls

# 上面的命令有什么问题吗？
# fastq中也存在a，是否也会被替换
# ehbio中也存在b，是否也会倍替换
# 执行后，文件名都乱套了

# 再重命名回去，再次尝试
rename 'Control' 'a' *
# 如果是 mac 执行下面的命令
# rename -s 'Control' 'a' *

# 查看结果
ls

# 重命名时加下划线, 这也是我们做匹配时常需要注意的，尽量限制让匹配的范围更精确
awk '{system("rename "$1"_ "$2"_ *.fastq.gz"); }' name.map.txt

# 如果是 mac 执行下面的命令
# awk '{system("rename -s "$1"_ "$2"_ *.fastq.gz"); }' name.map.txt


# 打印出来看下
awk '{print("rename "$1"_ "$2"_ *.fastq.gz"); }' name.map.txt

# 这次没问题了
ls

# 再看一个例子
touch A1_FRAS192317015-1a_1.fq.gz  A2_FRAS192320421-1a_1.fq.gz  A3_FRAS192317017-1a_1.fq.gz
touch A1_FRAS192317015-1a_2.fq.gz  A2_FRAS192320421-1a_2.fq.gz  A3_FRAS192317017-1a_2.fq.gz

# 查看文件名以 A 开头的文件
ls A*

# 中间的那一串字符FRA...-是我们不需要的。观察规律，先按下划线将文件名分割(_)，再获取第1,3个元素；
# 另外习惯性给生物重复前面也加上下划线（用到了sed的记忆匹配）。

ls A*.fq.gz | cut -f 1,3 -d '_' | sed 's/\([A-E]\)/\1_/'

# 把原样品名字与新样品名字对应起来，这里用到了paste和输入重定向 (<)
paste <(ls A*.fq.gz) <(ls A*.fq.gz | cut -f 1,3 -d '_' | sed 's/\([A-E]\)/\1_/')


# 使用mv直接重命名 （还可以把这个脚本保存下来，保留原始名字和新名字的对应关系，万一操作错了，
# 在看到结果异常时也可以方便回溯）
paste <(ls A*.gz) <(ls A*.gz | cut -f 1,3 -d '_' | sed 's/\([A-E]\)/\1_/') | sed 's#^#/bin/mv #'


# 软链接也是常用的 (但一定注意源文件使用全路径)
paste <(ls A*.gz) <(ls A*.gz | sed 's/\./_/' | cut -f 1,3,4 -d '_' | sed 's/\([A-E]\)/analysis\/\1_/') \
   | sed 's#^#ln -s `pwd`/#'


# 基于awk转换下输入数据的格式，字符处理在awk也可以操作，但我更习惯使用命令组合，每一步都用最简单的操作，
# 不容易出错。

# 采用awk生成对应关系,应该怎么做？


# 解析 metadata.txt文件

# 提取所有的样本名
cut -f 1 metadata.txt 

cut -f 1 metadata.txt | tail -n +2

cut -f 2 metadata.txt | tail -n +2 | sort -u 

cut -f 3 metadata.txt | tail -n +2 | sort | uniq -c

# 遍历所有样本
while IFS= read -r sample; do echo "$sample"; done < <(cut -f 1 metadata.txt | tail -n +2)

for i in `cut -f 1 metadata.txt | tail -n +2`; do echo $i; done

# name.map.txt 是映射表，不是 shell 脚本，不能用 bash 运行。

# 清理文件
mv example.fastq.gz  example.fq.gz 
rm rename.sh
printf '准备删除：\n'
printf '%s\n' A*.fq.gz Control*.fastq.gz Treatment*.fastq.gz
# 确认无误后再取消下一行注释：
# rm -- A*.fq.gz Control*.fastq.gz Treatment*.fastq.gz


# 练习

# 用 bash 命令完成下面的计算（可借助大语言模型或搜索引擎，
# 但运行前要解释命令、检查输入文件，并先用少量数据验证）。

# 1. 把下面的序列写入一个文件，命名为 test.fa，放在 02Linux 目录下。


cat <<END | sed '/^>/ s/$/----/' | tr -d '\n' | sed 's/----/\n/g' | sed 's/>/\n>/g' > test.fa
>SOX2
ACGTCGGCGGAGGGTGGSCGGGGGGGGAGAGGT
ACGATGAGGAGTAGGAGAGAGGAGG
>OCT4
ACGTAGGATGGAGGAGAGGGAGGGGGGAGGAGAGGAA
AGAGTAGAGAGA
>NANOG
ACGATGCGATGCAGCGTTTTTTTTTGGTTGGATCT
CAGGTAGGAGCGAGGAGGCAGCGGCGGATGCAGGCA
ACGGTAGCGAGTC
>mYC HAHA
ACGGAGCGAGCTAGTGCAGCGAGGAGCTGAGTCGAGC
CAGGACAGGAGCTA
END


# 2. 统计文件中的序列条数。
# 3. 从 test.fa 中提取 SOX2 的序列。
#    提示：设置 flag，只打印目标标题之后、下一个标题之前的序列行。
# 4. 从 test.fa 中分别提取包含 GGCAG、GGYGGA（Y=C/T）的序列行。
# 5. 计算每条序列的长度。


# 6. 02Linux/DESeq2.trt._vs_.untrt.results.xls 是 DESeq2 差异分析结果，基于此文件：
#    * 统计文件中的基因总数（注意是否有表头）
#    * 找出 log2FoldChange 最大的 10 个基因
#    * 以 |log2FoldChange| >= 1、padj < 0.05 为标准筛选差异基因，
#      分别输出 trt 中上调和 untrt 中上调的基因
   
# 7. 根据 02Linux/GRCh38.idmap.txt 中的 ID 对应关系，把差异分析结果转换为 2 个文件：
#    一个文件第一列使用 Gene symbol，另一个文件第一列使用 Entrez ID 命名。
#    缺少对应 Gene symbol 或 Entrez ID 的基因可忽略。
