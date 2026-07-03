#!/usr/bin/env perl
# 章节结构探查 + 分块建议
# 用法: perl chapter_map.pl 输入.txt [目标块大小KB，默认25]
# 输出: 章节标题行号表 + 按空行切割的分块方案（offset/limit 可直接用于 Read）
use strict;
use warnings;
use utf8;
binmode(STDOUT, ':encoding(UTF-8)');

die "用法: perl chapter_map.pl 输入.txt [块大小KB]\n" unless @ARGV >= 1;
my $target = ($ARGV[1] // 25) * 1024;

open(my $in, '<:encoding(UTF-8)', $ARGV[0]) or die "无法读取 $ARGV[0]: $!";
my (@lines, @chapters);
while (my $l = <$in>) {
    push @lines, $l;
    # 常见章节标题模式：第X卷/第X章/第X节/序章/尾声/后记/终章/番外/特典/插图
    if ($l =~ /^\s*(第[零一二三四五六七八九十百千0-9]+[卷章节回话]|序章|序幕|楔子|尾声|终章|后记|番外|插图|.{0,6}特典)/) {
        push @chapters, { line => scalar(@lines), title => ($l =~ s/^\s+|\s+$//gr) };
    }
}
close $in;

print "=== 章节结构 (共 ", scalar(@lines), " 行) ===\n";
printf "%6d | %s\n", $_->{line}, $_->{title} for @chapters;

# 分块：累计字节数达到目标后，在下一个空行处切；章节标题行优先作为新块起点
print "\n=== 分块建议 (目标 ", $target/1024, "KB/块) ===\n";
my %is_chapter = map { $_->{line} => 1 } @chapters;
my ($start, $bytes, $n) = (1, 0, 1);
for my $i (0 .. $#lines) {
    my $lineno = $i + 1;
    # 章节标题处：若当前块已过半，直接在标题前切，保证标题落在块首
    if ($is_chapter{$lineno} && $bytes > $target / 2 && $lineno > $start) {
        emit($n++, $start, $lineno - 1, $bytes);
        ($start, $bytes) = ($lineno, 0);
    }
    { use bytes; $bytes += length($lines[$i]); }
    # 超过目标且当前行是空行：在此切
    if ($bytes >= $target && $lines[$i] =~ /^\s*$/ && $lineno > $start) {
        emit($n++, $start, $lineno, $bytes);
        ($start, $bytes) = ($lineno + 1, 0);
    }
}
emit($n, $start, scalar(@lines), $bytes) if $start <= @lines;

sub emit {
    my ($num, $a, $b, $sz) = @_;
    printf "chunk_%02d: 行 %d-%d  (offset=%d, limit=%d, ~%.0fKB)\n",
        $num, $a, $b, $a, $b - $a + 1, $sz / 1024;
}
