#!/usr/bin/perl

#
# Base on a hacked around version of this: http://taskboy.com/blog/?bid=641
#

use strict;
use warnings;
use Audio::Wav;

my $outfile     = 'out.wav';
my $hertz       = 440;
my $seconds     = 0.1;
my $harms   = 1;
my $sample_rate = 44100; # CD quality;
my $bits_sample = 16;    # 4,8,16 are all good choices
my $volume_scalar = 1;

my $wav = Audio::Wav->new;
my $write = $wav->write($outfile, 
			{ 
			 bits_sample => $bits_sample,
			 sample_rate => $sample_rate,
			 channels    => 1,
			}
		       );

my $pi     = (22/7); # close enough;
my $len    = $seconds * $sample_rate;
my $max_no = (2 ** $bits_sample) / 2 * $volume_scalar;


my @vals=qw( 
    220 440 880 1760 3520 1760 880 440 220 220 440 880 1760 3520 7040
    );

my $mult=1;

for (my $i=0; $i<50; $i++)
{
  if ($i%3==0)
  {
    $harms='1,3';
  }
  elsif ($i%5==0)
  {
    $harms='1,5';
  }
  elsif ($i%7==0)
  {
    $harms='1,7';
  }
  elsif ($i%9==0)
  {
    $harms='1,3,5';
  }
  elsif ($i%11==0)
  {
    $seconds=0.8;
    $harms='1,3,5,7';
  }
  else
  {
    $harms=1;
  }

  for my $f (@vals)
  {
    $hertz=$f;
    writeit();
    $hertz=$f*$mult;
    writeit();
  }
  $seconds-=0.05;
  $mult=$mult*1.05;
  if ($seconds<0.04)
  {
    $seconds+=0.055;
  }
  if ($mult>1.8)
  {
    $mult=1;
  }
}

$write->finish;


sub writeit
{
  # split Harmonics value into an array
  my $harmonics = [ split /\s*,\s*/, $harms ];

  my $next = 0;
  for my $pos (0..$len) {
    my $hz = $hertz;

    # throw in some harmonics, but keep the tonic dominate
    if ($pos % 2 == 1) {
      $hz *= $harmonics->[$next++];
    }
    $next = 0 if $next >= @{$harmonics};

    my $time = ($pos/$sample_rate) * $hz;

    $write->write( sin($pi * $time) * $max_no );
  }
}
