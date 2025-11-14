BEGIN {
    print "# Generated configuration"
    # Add any initial configuration here if needed
}
{
    host = $0
    # Create identifier by replacing hyphens with underscores
    identifier = "exporter_" host
    gsub(/-/, "_", identifier)
    
    # Print the block with dynamic host values
    print "prometheus.scrape \"" identifier "\" {"
    print "    target = [{"
    print "        \"addr\" = \"127.0.0.1:8080\", \"server\" = \"" host "\","
    print "    }]"
    print "    scrape_interval = \"30s\""
    print "    scrape_timeout  = \"30s\""
    print "    metric_path     = \"/metrics\""
    print "    forward_to      = [prometheus.relabel.exporter.receiver]"
    print "    job_name        = \"exporter\""
    print "    params          = {\"target\" = [\"" host "x\"]}"
    print ""
    print "    clustering {"
    print "        enabled = true"
    print "    }"
    print "}\n"
}
