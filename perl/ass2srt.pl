#!/usr/bin/perl -w
use strict;
use encoding 'utf-8';
use Getopt::Long;
use File::Spec;

Getopt::Long::Configure( "pass_through", "no_ignore_case" );

# 預設編碼
my $defaultEnc  = 'utf8';
my $fromEnc     = '';
my $toEnc       = '';
my $help        = 0;
my $preserve    = 0;
my $combine     = 0;
my $showVer     = 0;
my $showLicense = 0;
my $dosFormat   = 0;
my $macFormat   = 0;

my $oldTime = "";

$fromEnc = $ENV{'ASS2SRT_FROM'};
$toEnc   = $ENV{'ASS2SRT_TO'};

GetOptions(
    "help|h",     \$help,      "from|f=s",    \$fromEnc,
    "to|t=s",     \$toEnc,     "default|d=s", \$defaultEnc,
    "preserve|p", \$preserve,  "combine|c",   \$combine,
    "version|v",  \$showVer,   "dos|o",       \$dosFormat,
    "mac|m",      \$macFormat, "license|l",   \$showLicense
);

# 換行格式
my $crlf = "\n";

# 若同時指定輸出成 Mac 及 DOS 格式時，回覆錯誤訊息並結束
( $dosFormat && $macFormat )
    && die(
    "\n錯誤: \n\t選項 -m|--mac 與 -o|--dos 不可同時存在 \n");

if ($dosFormat) { $crlf = "\r" . $crlf; }
if ($macFormat) { $crlf = "\r"; }

# 程式版本
my $version = "0.2.4.2";

# 顯示求助訊息
if ($help) { usage(); }

# 顯示授權資訊
if ($showLicense) { license(); }

# 顯示版本訊息
if ($showVer) { showVersion(); }

# 未指定來源檔編碼時，設為與 defaultEnc 相同
if ( !$fromEnc ) { $fromEnc = $defaultEnc; }

# 未指定目的檔編碼時，設為與 defaultEnc 相同
if ( !$toEnc ) { $toEnc = $defaultEnc; }

# .ass 檔檔名
my $assFile = shift || '';
if ( !$assFile ) { usage(); }

# .srt 檔檔名，預設值同 .ass 檔名，但副檔名改為 .srt
my $srtFile = shift || '';
if ( !$srtFile ) {
    $srtFile = $assFile;
    $srtFile =~ s|\.[^.]*$||;
    $srtFile .= ".srt";
}

# 列出使用參數
print "Using parameters: \n";
print "\t .ASS File Encoding: $fromEnc\n";
print "\t .SRT File Encoding: $toEnc\n";
print "\n";

# 開檔
open( ASSFILE, "<", $assFile )
    or die '無法開啟 ".ass" 來源檔：' . $assFile . ", 請檢查！\n";
open( SRTFILE, ">", $srtFile )
    or die '無法開啟 ".srt" 目的檔：' . $srtFile . ", 請檢查！\n";

# 指定檔案編碼
binmode( ASSFILE, ':encoding(' . $fromEnc . ')' );

# 檢查是否存在系統環境變數 OS ( Windows 上應該會有 )
my $OS_TYPE = $ENV{'OS'};

# 指定寫檔時使用的編碼設定字串
my $toEncString = ':encoding(' . $toEnc . ')';

# 依 OS 種類 ( 僅針對 Windows ) 修正開檔編碼
if ( $OS_TYPE && $OS_TYPE =~ m/windows/i ) {
    print "Operation System is: " . $OS_TYPE
        . ", Checking File Encoding... \n";

    # 只有使用 UTF16 或 UCS 格式時才另行指定（其他待測）
    if ( ( $toEnc =~ m/utf16/i ) || ( $toEnc =~ m/ucs/i ) ) {
        $toEncString = ':raw' . $toEncString;
    }
}

# 指定寫檔時使用的編碼
binmode( SRTFILE, $toEncString );

# Windows 上輸出 Unicode 檔時要加入 BOM 識別記號
if ( $toEncString =~ m/:raw/i ) {
    print SRTFILE "\x{FEFF}";
    print "Using unicode encoding, print BOM signature to file: " . $srtFile
        . "\n\n";
}

# 記錄字幕筆數
my $line = 0;

# 讀入 .ass 來源檔並處理
while (<ASSFILE>) {
    chomp;

    # 若是以 Dialougue 起頭者，為字幕設定
    if (m/^Dialogue:/) {
        $line = writeSrt( $line, $_ );

        # 若為 Title 或 Original 起頭者，為字幕來源說明
    }
    elsif (m/^(Title:|Original)/) {
        print $_ . "\n";
    }

}

# 關閉檔案
close ASSFILE;
close SRTFILE;

# 寫入 .srt 檔
sub writeSrt {

    # 處理行數
    my $line = $_[0];

    # 來自 .ass 的原始內容
    my $content = $_[1];

    my $begin;
    my $end;
    my $subtitle;
    my $currentTime;

    # 解出 起始時間、結束時間、字幕格式、字幕內容
    if ( $content
        =~ m/Dialogue: [^,]*,([^,]*),([^,]*),([^,]*),[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,(.*)$/
        )
    {
        $begin    = $1;
        $end      = $2;
        $subtitle = $4;

        my $isComment = $3;

        # the separator between seconds and ms is "," -- not "."
        $begin =~ s/\./\,/g;
        $end   =~ s/\./\,/g;

        # 若時間格式的小時部份不會 2 碼時，補足兩碼
        if ( $begin =~ m/^\d{1}:/ ) {
            $begin = "0" . $begin;
        }

        if ( $end =~ m/^\d{1}:/ ) {
            $end = "0" . $end;
        }

# 先濾除每句字幕末端的歸位符號，以便後續輸出各種不同平台下的格式
        $subtitle =~ s/\r$//g;

        # 若沒有設定保留 .ass 的控制指令，則濾除之
        if ( !$preserve ) {
            $subtitle =~ s/\{\\[^}]*\}//g;
        }

        # 若字幕格式為 comment 時，則在前後加上 ( )
        if ( $isComment eq 'comment' ) {
            $subtitle = '(' . $subtitle . ')';
        }

  # 寫入 .srt 檔
  # 因 .ass 時間單位 ( 10ms ) 與 .srt ( 1ms ) 不同，故全部補個 0
        $currentTime = $begin . "0 --> " . $end . "0";

        $subtitle =~ s/\\N/$crlf/g;

        # 時間軸合併輸出模式
        if ($combine) {

            if ( $oldTime eq $currentTime ) {
                print SRTFILE $subtitle;
            }
            else {
                $line++;
                if ( $line > 0 ) {
                    print SRTFILE $crlf . $crlf . $crlf . $line . $crlf;
                }
                else {
                    print SRTFILE $line . $crlf;
                }
                print SRTFILE $currentTime . $crlf;
                print SRTFILE $subtitle;
            }
            $oldTime = $currentTime;
        }
        else {

            # 一般輸出模式
            $line++;
            print SRTFILE $line . $crlf;
            print SRTFILE $currentTime . $crlf;
            print SRTFILE "$subtitle " . $crlf . $crlf . $crlf;
        }

        return $line;
    }
}

# 使用說明
sub usage {
    print <<__HELP__;

ass2srt [選項] .ass 來源檔 [.srt 目的檔]

    將 Advanced SubStation Aplha ".ass" 檔案格式轉為 SubRip ".srt" 格式。 

選項:
  -h --help               顯示本求助訊息
    
  -d, --default=encoding  設定預設檔案編碼，也就是來源檔與目的檔使用同編碼。
                          預設值為 UTF-8 編碼格式。
                                     
  -f, --from=encoding     指定來源檔 .ass 所使用的編碼系統。本設定會覆蓋前述預
                          設檔案編碼之設定，未指定時以預設檔案編碼為其預設值。  
                       ※ 也可以使用系統環境變數 ASS2SRT_FROM 指定
                                
  -t, --to=encoding       指定目的檔 .srt 所使用的編碼系統。本設定會覆蓋前述預
                          設檔案編碼之設定，未指定時以預設檔案編碼為其預設值。
                       ※ 也可以使用系統環境變數 ASS2SRT_TO 指定

  -p, --preserve          保留來源檔 .ass 中的字幕控制指令，一併寫入 .srt 檔中。

  -c, --combine	          合併多個相同時間軸設定的字幕內容到單一時間軸之下。
  
  -o, --dos               指定輸出檔案格式為 DOS （預設為 Unix 格式）
                       ※ 不可與 -m/--mac 同時設定
  
  -m, --mac               指定輸出檔案格式為 Mac （預設為 Unix 格式）                
                       ※ 不可與 -o/--dos 同時設定

.ass 來源檔：
    符合 Advanced SubStation Alpha (.ass) 或 SubStation Alpha (.ssa) 格式
    之原始字幕檔。 

[.srt 目的檔]：
    預設輸出的 SubRip 格式的目的檔檔名，預設值與 .ass 來源檔 相同，
    但副檔名改為 .srt 。

操作範例：

  1. 將 Unicode/UTF-16 LE 編碼的 .ass 來源檔轉成以 Big5 編碼的 .srt 目的檔
  
      myhost\$ perl ass2srt.pl -f utf16-le -t big5 utf16-le.ass big5.srt
      
  2. 將 Big5 編碼的 .ass 來源檔轉成以 UTF-8 編碼的 .srt 目的檔
    
      myhost\$ perl ass2srt.pl -f big5 -t utf8 big5.ass utf8.srt
      
  3. 將 UTF-8 編碼的 .ass 來源檔轉成以 UTF-8 編碼的 .srt 目的檔
  
      myhost\$ perl ass2srt.pl utf-8.ass utf-8.srt
      
  4. 將 UCS-2LE 編碼的 .ass 來源檔轉成 UCS-2LE 編碼的 .srt 目的檔
  
      myhost\$ perl ass2srt.pl -f ucs-2le -t ucs-2le ucs-2le.ass ucs-2le.srt
      
  5. 透過環境變數指定編碼種類
     ※ 某些作業系統中請勿對設定值前後加上 " 或 ' 引號
  
      myhost\$ export ASS2SRT_FROM=utf16-le
      myhost\$ export ASS2SRT_TO=big5
      myhost\$ perl ass2srt.pl utf16-le.ass big5.srt                               

__HELP__
    exit 2;
}

# 顯示版本訊息
sub showVersion {

    print <<__VERSION__;

ass2srt $version - Convert subtitles from .ass to .srt format
	
  Advanced SubStation Alpha 字幕檔格式轉檔工具
  (c) 2006 Ada Hsu, hungwei.hsu (at) gmail (dot) com

__VERSION__
    exit 2;
}

# 軟體授權
sub license {

    print <<__LICENSE__;

  ass2srt $version - Convert subtitles from .ass to .srt format

  Advanced SubStation Alpha 字幕檔格式轉檔工具
  (c) 2006 Ada Hsu, hungwei.hsu (at) gmail (dot) com
  
  本軟體採用 CC-GNU GPL (http://creativecommons.org/licenses/GPL/2.0/) 授權，
  您可在 http://www.gnu.org/copyleft/gpl.html 中查看相關條款內文。
  
  您可自由使用本軟體，但本軟體的維護人員將不對因使用本軟體所造成的各項軟、硬
  體傷害或損失負任何責任。

__LICENSE__
    exit 2;

}
