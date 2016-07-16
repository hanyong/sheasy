#!/usr/bin/python2
import sys

def main():
	sudoStart = "Match Group sudo"
	sudoRule = "PasswordAuthentication no"
	hasSudo = False
	hasSudoRule = False
	for line in sys.stdin:
		if line.strip().startswith(sudoStart):
			if not hasSudo:
				hasSudo = True
			else:
				raise Exception("multi sudo block")
		elif not hasSudoRule:
			# if hasSudo, we could make sure hasSudoRule before sudo end.
			if hasSudo:
				# sudo end, append sudoRule
				if line.startswith("Match "):
					print "\t" + sudoRule
					hasSudoRule = True
				# we found sudoRule
				elif line.strip().startswith(sudoRule):
					hasSudoRule = True
		print line,
	if not hasSudoRule:
		if not hasSudo:
			print sudoStart
		print "\t" + sudoRule
		hasSudoRule = True

if __name__ == '__main__':
	main()
