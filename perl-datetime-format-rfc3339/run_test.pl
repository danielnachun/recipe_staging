my $expected_version = "v1.2.";
print("import: DateTime::Format::RFC3339\n");
use DateTime::Format::RFC3339;

if (defined DateTime::Format::RFC3339->VERSION) {
	my $given_version = DateTime::Format::RFC3339->VERSION;
	$given_version =~ s/0+$//;
	die('Expected version ' . $expected_version . ' but found ' . $given_version) unless ($expected_version eq $given_version);
	print('	using version ' . DateTime::Format::RFC3339->VERSION . '
');

}
my $expected_version = "v1.2.";
print("import: DateTime::Format::RFC3339\n");
use DateTime::Format::RFC3339;

if (defined DateTime::Format::RFC3339->VERSION) {
	my $given_version = DateTime::Format::RFC3339->VERSION;
	$given_version =~ s/0+$//;
	die('Expected version ' . $expected_version . ' but found ' . $given_version) unless ($expected_version eq $given_version);
	print('	using version ' . DateTime::Format::RFC3339->VERSION . '
');

}
