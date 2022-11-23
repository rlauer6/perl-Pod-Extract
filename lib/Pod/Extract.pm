#!/usr/bin/env perl
package Pod::Extract;

use strict;
use warnings;

use Getopt::Long;
use Data::Dumper;

use Carp;
use IO::Scalar;

our $VERSION = '0.01';

use Readonly;

Readonly our $TRUE  => 1;
Readonly our $FALSE => 0;
Readonly our $EMPTY => q{};

Readonly our $POD_START => qr/^=(?:pod|begin)/xsm;
Readonly our $POD_END   => qr/^=(?:cut|end)/xsm;

our @EXPORT = qw(extract_pod);

caller or __PACKAGE__->main();

########################################################################
sub usage {
########################################################################

  print <<'END_OF_HELP';
usage: podextract options

Options
-------
--infile, -i   input file
--outfile, -o  file to write code to 
--podfile, -p  file to write pod to

If --infile is not specified, script reads from stdin
If --outfile is not specified, code is written to stdout
If --podfiel is not specified, pod is written to stderr

END_OF_HELP
  return;
}

########################################################################
sub extract_pod {
########################################################################
  my ($fh) = @_;

  my %pod_sections;

  my $pod = <<'END_OF_POD';

## no critic (RequirePodSections)

__END__

END_OF_POD
  $pod .= "=pod\n";

  my $code = $EMPTY;

  my $pod_out = IO::Scalar->new( \$pod );

  my $code_out = IO::Scalar->new( \$code );

  my $in_pod = $FALSE;

  while ( my $line = <$fh> ) {

    if ( $line =~ $POD_START ) {
      $in_pod = $TRUE;
      next;
    }

    if ( $line =~ $POD_END ) {
      $in_pod = $FALSE;

      next;
    }

    if ( !$in_pod ) {
      print {$code_out} $line;
    }
    else {
      print {$pod_out} $line;
    }

    if ( $line =~ /^=([\S]+)\s+(.*)\s+$/xsm ) {

      my ( $section, $title ) = ( $1, $2 );

      next if $section !~ /head/xsm;

      $pod_sections{$section} //= [];

      push @{ $pod_sections{$section} }, $title;
    }
    else {
      next;
    }
  }

  print {$pod_out} "=cut\n";

  close $pod_out;

  close $code_out;

  my %result = (
    pod   => $pod,
    code  => $code,
    stats => \%pod_sections,
  );

  return wantarray ? ( $pod, $code, \%pod_sections ) : \%result;
}

########################################################################
sub write_file {
########################################################################
  my ( $file, $text ) = @_;

  my $fh;

  if ( !ref $file && !fileno $file ) {

    open $fh, '>', $file  ## no critic (RequireBriefOpen)
      or croak "could not open $file for writing";
  }
  else {
    $fh = $file;
  }

  print {$fh} $text;

  return close $fh;
}

########################################################################
sub main {
########################################################################
  my %options;

  GetOptions( \%options, 'help', 'infile=s', 'outfile=s', 'podfile=s', );

  if ( $options{help} ) {
    usage();

    return 0;
  }

  if ( $options{infile} ) {
    open my $fh, '<', $options{infile}  ## no critic (RequireBriefOpen)
      or croak "could not open $options{infile}";

    $options{infile} = $fh;
  }

  my $result = extract_pod( $options{infile} // *STDIN );

  $options{outfile} //= *STDOUT;

  write_file( $options{outfile}, $result->{code} );

  $options{podfile} //= *STDERR;

  write_file( $options{podfile}, $result->{pod} );

  return 0;
}

1;

## no critic (RequirePodSections)

__END__

=pod

=head1 NAME

Pod::Extract - remove pod from file

=head1 SYNOPSIS

 use Pod::Extract;

 open my $fh, '<', 'myfile.pm';

 my ($pod, $code, $sections) = extract_pod($fh);

=head1 DESCRIPTION

Parse a Perl script or module looking for pod. Returns the pod and
code in separate objects.

This module does not attempt to check the validity of the pod
syntax. It's just a simple parser that looks for that might pass as
pod within your code. If you've done something odd, don't expect this
module to figure it out.

This module was a result of refactoring lots of Perl modules that had
pod scattered about the module on the basis of Perl Best Practices
recommendations to place pod at the end of a module. In addition to
the obvious standardization this provides for an application, it was
an eye-opening experience find all the pod errors. ;-)

=head1 USAGE

From the command line...

 podextract --infile=myfile.pm --outfile=myfile-without-pod.pm --podfile = myfile.pod

 podextract --help

=head1 METHODS AND SUBROUTINES

=head2 extract_pod

 extract_pod( file-handle ) 

In list context returns a three element list consisting of the pod,
the code and a hash with section names. In scalar context returns a
hash consisting of the keys C<pod>, C<code> and C<sections>
representing the same objects in list context.

=over 5

=item pod

The pod text contained in the script or module in the order it was encountered.

=item code

The code text with the pod removed.

=item sections

A hash reference containing the section and section titles.

=back

=head1 AUTHOR

Rob Lauer - rclauer@gmail.com

=head1 SEE OTHER

=cut
