my $expected_version = "0.011";
print("import: MooX::StrictConstructor\n");

if (defined MooX::StrictConstructor->VERSION) {
	my $given_version = MooX::StrictConstructor->VERSION;
	$given_version =~ s/0+$//;
	die('Expected version ' . $expected_version . ' but found ' . $given_version) unless ($expected_version eq $given_version);
	print('	using version ' . MooX::StrictConstructor->VERSION . '
');

}
my $expected_version = "0.011";
print("import: MooX::StrictConstructor\n");

if (defined MooX::StrictConstructor->VERSION) {
	my $given_version = MooX::StrictConstructor->VERSION;
	$given_version =~ s/0+$//;
	die('Expected version ' . $expected_version . ' but found ' . $given_version) unless ($expected_version eq $given_version);
	print('	using version ' . MooX::StrictConstructor->VERSION . '
');

}
