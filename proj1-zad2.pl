#!/usr/bin/perl -w  
use strict;
use v5.10;
use Tk;
use Tk::FileSelect;
use MLDBM 'DB_File';
	 
my $file;
my $word;
my $regex;

#GUI
my $mw = MainWindow->new;
my $main_frame = $mw->Frame()->pack;
my $right_frame = $main_frame->Frame( -background => "white")->pack(-side => "right");
my $output_window = $right_frame->Text(-background => "white",-foreground => "black")->pack(-side => "top");

$main_frame->Button(-text => 'Select file', -command => \&select_file)->pack;
$main_frame->Button(-text => 'Index file',-command => \&index_file)->pack;
my $word_entry = $main_frame->Entry()->pack;
$main_frame->Button(-text  => 'Find word or regex', -command => \&find_word)->pack;
$main_frame->Button(-text => "Clear Text",-command => sub { $output_window->delete('0.0', 'end') })->pack;
$main_frame->Button(-text => 'Quit', -command => sub { exit } )->pack;

MainLoop;

#Selects file for indexing or word look-up
sub select_file {
my $FSref = $mw->FileSelect(-directory => ".");
$file = $FSref->Show();
}

#Indexes a file
sub index_file {
  if (!$file) {
    $mw->messageBox(-message => "Select a file first", -type => "ok");
  } 
  else {
    my %index;
    open my $fh, '<', $file or die "Can't open $file"; 

#If the word is found, the line nummber($.) is stored in %index
    while (<$fh>) {
      push @{$index{$1}}, $. while /(\w+)/g;
    }
    
    $output_window->delete('0.0', 'end');
    for my $word (keys %index) {
    $output_window->insert("end",  "$word:  @{$index{$word}}\n");
    #say "$word:  @{$index{$word}}";
    }

#Ties %index to index.dbm file 
    tie(%index, 'MLDBM', 'index.dbm') or die $!;
  }
}  

#Finds a word or regex
sub find_word {
$word = $word_entry->get();

  if (!$file) {
    $mw->messageBox(-message => "Select a file, first.", -type => "ok");
  }
  elsif (!$word) {
    $mw->messageBox(-message => "Enter a word or a regular expression.", -type => "ok");
  }
  else {
    my $line_number = 0;
    open my $fh, $file or die "Can't open $file";
    $output_window->delete('0.0', 'end');
    while (my $line = <$fh>) {
      $line_number++;
      if ($line =~ /$word/) {
        $output_window->insert("end",  "Line number: $line_number - ");
        $output_window->insert("end",  $line);
        #print "Line number: $line_number - ";
        #print $line;
      }
    }
}
}
