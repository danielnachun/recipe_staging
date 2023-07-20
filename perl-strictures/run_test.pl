my $expected_version1 = "2.000006";
print("import: strictures\n");
use strictures;

if (defined strictures->VERSION) {
	my $given_version1 = strictures->VERSION;
	$given_version1 =~ s/0+$//;
	die('Expected version ' . $expected_version1 . ' but found ' . $given_version1) unless ($expected_version1 eq $given_version1);
	print('	using version ' . strictures->VERSION . '
');

}
my $expected_version2 = "2.000006";
print("import: strictures\n");
use strictures;

if (defined strictures->VERSION) {
	my $given_version2 = strictures->VERSION;
	$given_version2 =~ s/0+$//;
	die('Expected version ' . $expected_version2 . ' but found ' . $given_version2) unless ($expected_version2 eq $given_version2);
	print('	using version ' . strictures->VERSION . '
');

}
