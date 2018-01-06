#!/usr/bin/perl -w

my %suf = (
	KB => 1e3,
	MB => 1e6,
);
print '$suf{MB} = ', $suf{MB}, "\n";
print '$suf{KB} = ', $suf{KB}, "\n";
while (<>) {
	my @F=();
   	while (/\((\d+)(.B)\)/g) {
		my $mul = $suf{$2};
	   	push @F, $1 * $suf{"$2"};
	}
	@F = sort {$a<=>$b} @F;
	my $sum = 0;
	for (my $i = 0; $i < scalar(@F); $i++) {
		$sum += $F[$i];
	}
	#print "max/sum = ", $F[$#F] / $smallsum, "\n";
	my $max = $F[$#F];
	if (scalar(@F) >= 2) {
		printf("%9.6f  %9.6f  %9.6f ; %s\n", $sum / $max, $max / ($sum - $max), $max/$sum, join(' ', @F));
	}
}
