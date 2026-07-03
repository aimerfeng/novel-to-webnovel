#!/usr/bin/env perl
# 机械格式清理：「」→“”、『』→‘’、删假名注音、去段首缩进
# 用法: perl format_clean.pl 输入.txt 输出.txt
use strict;
use warnings;
use utf8;
use Encode ();
binmode(STDOUT, ':encoding(UTF-8)');
binmode(STDERR, ':encoding(UTF-8)');
# 文件名参数保持原始字节用于 open，仅显示时解码
my $show_out = eval { Encode::decode('UTF-8', $ARGV[1] // '', Encode::FB_DEFAULT) } // ($ARGV[1] // '');

die "用法: perl format_clean.pl 输入.txt 输出.txt\n" unless @ARGV == 2;
open(my $in,  '<:encoding(UTF-8)', $ARGV[0]) or die "无法读取 $ARGV[0]: $!";
open(my $out, '>:encoding(UTF-8)', $ARGV[1]) or die "无法写入 $ARGV[1]: $!";

while (my $line = <$in>) {
    # 删除假名注音：（くるみ） / (むつき) 等（平假名+片假名+长音符）
    $line =~ s/[（(][\x{3041}-\x{3096}\x{30A1}-\x{30FA}\x{30FB}\x{30FC}]+[）)]//g;
    # 「」→ “”，『』→ ‘’
    $line =~ s/「/\x{201C}/g;
    $line =~ s/」/\x{201D}/g;
    $line =~ s/『/\x{2018}/g;
    $line =~ s/』/\x{2019}/g;
    # 去掉段首的全角/半角空格缩进
    $line =~ s/^[ \x{3000}]+//;
    print $out $line;
}
close $in;
close $out;
print "完成: $show_out\n";
