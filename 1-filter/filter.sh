# use mothur to filter raw datas
# maxlength=1600, minlength=1400 reads长度筛选
# maxambig=0 去除ambiguous base序列
# maxhomop=6 去除含6 bp以上的homopolymers的序列
# qaverage=35, qwindowsize=50 去除平均质量小于35的序列（窗口大小为50bp）
trim.seqs(fasta=combined_seqs.fna, maxlength=1600, minlength=1400, maxambig=0, maxhomop=6, qaverage=35, qwindowsize=50)
summary.seqs(fasta=combined_seqs.trim.fasta)


