# NAME

Pod::Extract - remove pod from file

# SYNOPSIS

    use Pod::Extract;

    open my $fh, '<', 'myfile.pm';

    my ($pod, $code, $sections) = extract_pod($fh);

# DESCRIPTION

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

# USAGE

From the command line...

    podextract --infile=myfile.pm --outfile=myfile-without-pod.pm --podfile = myfile.pod

    podextract --help

# METHODS AND SUBROUTINES

## extract\_pod

    extract_pod( file-handle ) 

In list context returns a three element list consisting of the pod,
the code and a hash with section names. In scalar context returns a
hash consisting of the keys `pod`, `code` and `sections`
representing the same objects in list context.

- pod

    The pod text contained in the script or module in the order it was encountered.

- code

    The code text with the pod removed.

- sections

    A hash reference containing the section and section titles.

# AUTHOR

Rob Lauer - rclauer@gmail.com

# SEE OTHER
