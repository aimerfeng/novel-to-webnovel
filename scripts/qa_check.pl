#!/usr/bin/env perl
# 质量校验：残留日式标点/注音/黑名单网感词/翻译腔标记 统计
# 用法: perl qa_check.pl 文件1.txt [文件2.txt ...]
# 退出码: 0=全部干净, 1=有残留
use strict;
use warnings;
use utf8;
use Encode ();
binmode(STDOUT, ':encoding(UTF-8)');
# 文件名参数保持原始字节用于 open，仅显示时解码
sub show { eval { Encode::decode('UTF-8', $_[0], Encode::FB_DEFAULT) } // $_[0] }

die "用法: perl qa_check.pl 文件.txt [...]\n" unless @ARGV;

my @checks = (
    [ '残留「」',    qr/[「」]/ ],
    [ '残留『』',    qr/[『』]/ ],
    [ '假名注音',    qr/[（(][\x{3041}-\x{3096}\x{30A1}-\x{30FA}\x{30FC}]+[）)]/ ],
    [ '游离假名',    qr/[\x{3041}-\x{3096}\x{30A1}-\x{30FA}]/ ],
    [ '段首缩进',    qr/^[ \x{3000}]+\S/ ],
    [ '黑名单网感词', qr/YYDS|绝绝子|栓Q|芭比Q|夺笋|awsl|xswl|耗子尾汁|u1s1/i ],
    [ '翻译腔:不禁',  qr/不禁/ ],
    [ '翻译腔:令人',  qr/令人(?:叹服|无言|困扰)/ ],
);

my $dirty = 0;
for my $file (@ARGV) {
    open(my $in, '<:encoding(UTF-8)', $file) or do { warn "跳过 ", show($file), ": $!\n"; next };
    my %hits; my %sample;
    while (my $l = <$in>) {
        for my $c (@checks) {
            if ($l =~ $c->[1]) {
                $hits{$c->[0]}++;
                $sample{$c->[0]} //= "行$.: " . substr($l =~ s/^\s+|\s+$//gr, 0, 30);
            }
        }
    }
    close $in;
    if (%hits) {
        $dirty = 1;
        print "✗ ", show($file), "\n";
        printf "    %-14s %4d 处  例: %s\n", $_, $hits{$_}, $sample{$_}
            for sort keys %hits;
    } else {
        print "✓ ", show($file), " 干净\n";
    }
}
# 注：翻译腔和黑名单项是提示性的（改写块应为0；未改写的原样区段命中属正常）
exit $dirty;
