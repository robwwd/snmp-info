# SNMP::Info::Layer2::Aironet
# Max Baker <max@warped.org>
#
# Copyright (c) 2003 Regents of the University of California
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the documentation
#       and/or other materials provided with the distribution.
#     * Neither the name of the University of California, Santa Cruz nor the 
#       names of its contributors may be used to endorse or promote products 
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package SNMP::Info::Layer2::Aironet;
$VERSION = 0.7;
# $Id$
use strict;

use Exporter;
use SNMP::Info::Layer2;
use SNMP::Info::Entity;
use SNMP::Info::EtherLike;

@SNMP::Info::Layer2::Aironet::ISA = qw/SNMP::Info::Layer2 SNMP::Info::Entity SNMP::Info::EtherLike Exporter/;
@SNMP::Info::Layer2::Aironet::EXPORT_OK = qw//;

use vars qw/$VERSION %FUNCS %GLOBALS %MIBS %MUNGE $AUTOLOAD $INIT $DEBUG/;

# Set for No CDP
%GLOBALS = (
            %SNMP::Info::Layer2::GLOBALS,
            %SNMP::Info::Entity::GLOBALS,
            %SNMP::Info::EtherLike::GLOBALS,
            'serial' => 'entPhysicalSerialNum.1',
            'descr'  => 'sysDescr'
            );

%FUNCS   = (%SNMP::Info::Layer2::FUNCS,
            %SNMP::Info::Entity::FUNCS,
            %SNMP::Info::EtherLike::FUNCS
            );

%MIBS    = (
            %SNMP::Info::Layer2::MIBS,
            %SNMP::Info::Entity::MIBS,
            %SNMP::Info::EtherLike::MIBS
            );

%MUNGE   = (%SNMP::Info::Layer2::MUNGE,
            %SNMP::Info::Entity::MUNGE,
            %SNMP::Info::EtherLike::MUNGE
            );


sub vendor {
    # Sorry, but it's true.
    return 'cisco';
}

sub interfaces {
    my $aironet = shift;
    my $i_description = $aironet->i_description();

    return $i_description;
}

# Tag on e_descr.1
sub description {
    my $aironet = shift;
    my $descr = $aironet->descr();
    my $e_descr = $aironet->e_descr();

    $descr = "$e_descr->{1}  $descr" if defined $e_descr->{1};

    return $descr;
}

# Fetch duplex from EtherLike
sub i_duplex {
    my $aironet = shift;
    my $el_duplex = $aironet->el_duplex();

    my %i_duplex;
    foreach my $d (keys %$el_duplex){
        my $val = $el_duplex->{$d};
        next unless defined $val;
        $i_duplex{$d} = 'full' if $val =~ /full/i;
        $i_duplex{$d} = 'half' if $val =~ /half/i;
    }

    return \%i_duplex;
}

1;
__END__

=head1 NAME

SNMP::Info::Layer2::Aironet - SNMP Interface to Cisco Aironet devices running IOS.

=head1 AUTHOR

Max Baker (C<max@warped.org>)

=head1 SYNOPSIS

 # Let SNMP::Info determine the correct subclass for you. 
 my $aironet = new SNMP::Info(
                          AutoSpecify => 1,
                          Debug       => 1,
                          # These arguments are passed directly on to SNMP::Session
                          DestHost    => 'myswitch',
                          Community   => 'public',
                          Version     => 2
                        ) 
    or die "Can't connect to DestHost.\n";

 my $class      = $aironet->class();
 print "SNMP::Info determined this device to fall under subclass : $class\n";

=head1 DESCRIPTION

Provides interface to SNMP Data available on newer Aironet devices running Cisco IOS.

Note there are two classes for Aironet devices :

=over

=item SNMP::Info::Layer3::Aironet

This class is for devices running Aironet software (older)

=item SNMP::Info::Layer2::Aironet

This class is for devices running Cisco IOS software (newer)

=back

For speed or debugging purposes you can call the subclass directly, but not after determining
a more specific class using the method above. 

my $aironet = new SNMP::Info::Layer2::Aironet(...);

=head2 Inherited Classes

=over

=item SNMP::Info::Layer2

=item SNMP::Info::Entity

=item SNMP::Info::EtherLike

=back

=head2 Required MIBs

=over

=item Inherited Classes

MIBs required by the inherited classes listed above.

=back

=head1 GLOBALS

These are methods that return scalar value from SNMP

=over

=item $aironet->discription()

Adds info from method e_descr() from SNMP::Info::Entity

=item $aironet->vendor()

    Returns 'cisco' :)

=back

=head2 Globals imported from SNMP::Info::Layer2

See documentation in SNMP::Info::Layer2 for details.

=head2 Globals imported from SNMP::Info::Entity

See documentation in SNMP::Info::Entity for details.

=head2 Globals imported from SNMP::Info::EtherLike

See documentation in SNMP::Info::EtherLike for details.

=head1 TABLE ENTRIES

=head2 Overrides

=over

=item $aironet->interfaces()

Uses the i_description() field.

=item $aironet->i_duplex()

Crosses information from SNMP::Info::EtherLike to get duplex info for interfaces.

=back

=head2 Table Methods imported from SNMP::Info::Layer2

See documentation in SNMP::Info::Layer2 for details.

=head2 Table Methods imported from SNMP::Info::Entity

See documentation in SNMP::Info::Entity for details.

=head2 Table Methods imported from SNMP::Info::EtherLike

See documentation in SNMP::Info::EtherLike for details.

=cut