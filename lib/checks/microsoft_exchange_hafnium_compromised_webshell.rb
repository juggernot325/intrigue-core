module Intrigue
module Issue
  class MicrosoftExchangeHafniumCompromisedWebshell < BaseIssue
    def self.generate(instance_details={})
    {
      added: "2021-03-10",
      name: "microsoft_exchange_hafnium_compromised_webshell",
      pretty_name: "Microsoft Exchange Hafnium Compromised Webshell",
      identifiers: [
      ],
      severity: 1,
      status: "potential",
      category: "compromise",
      description: "A webshell was found related to a known compromise",
      remediation: "Inspect the server for compromise",
      affected_software: [
        { :vendor => "Microsoft", :product => "Exchange Server" }
      ],
      references: [
        { type: "description", uri: "https://github.com/PwnDefend/Exchange-RCE-Detect-Hafnium/blob/main/honeypot_shell_list.txt" },
        { type: "remediation", uri: "https://www.bleepingcomputer.com/news/security/microsofts-msert-tool-now-finds-web-shells-from-exchange-server-attacks/"},
        { type: "remediation", uri: "https://github.com/microsoft/CSS-Exchange/tree/main/Security"},
        { type: "threat_intel", uri: "https://www.bleepingcomputer.com/news/security/microsofts-msert-tool-now-finds-web-shells-from-exchange-server-attacks/"},
        { type: "threat_intel", uri: "https://github.com/PwnDefend/Exchange-RCE-Detect-Hafnium/blob/main/honeypot_shell_list.txt"},
        { type: "threat_intel", uri: "https://redcanary.com/blog/microsoft-exchange-attacks/"},
        { type: "threat_intel", uri: "https://gist.github.com/JohnHammond/0b4a45cad4f4ed3324939d72dc599883"},
        { type: "threat_intel", uri: "https://www.bankinfosecurity.com/at-least-10-apt-groups-exploiting-exchange-flaws-a-16166"},




      ],
      authors: ["jcran", "pwndefend"]
    }.merge!(instance_details)
    end

  end
end


module Task
  class MicrosoftExchangeHafniumCompromisedWebshell < BaseCheck
    def self.check_metadata
      {
        allowed_types: ["Uri"],
        example_entities: [{"type" => "Uri", "details" => {"name" => "https://intrigue.io"}}],
        allowed_options: []
      }
    end

    def check
      # first, ensure we're fingerprinted
      require_enrichment

      known_webshell_paths = <<-eos
/aspnet_client/supp0rt.aspx
/aspnet_client/discover.aspx
/aspnet_client/shell.aspx
/aspnet_client/help.aspx
/aspnet_client/HttpProxy.aspx
/aspnet_client/0QWYSEXe.aspx
/aspnet_client/system_web/error.aspx
/aspnet_client/OutlookEN.aspx
/aspnet_client/sol.aspx
/aspnet_client/aspnettest.aspx
/aspnet_client/shellex.aspx
/aspnet_client/error_page.aspx
/aspnet_client/aspnet_client.aspx
/aspnet_client/iispage.aspx
/aspnet_client/system_web/log.aspx
/aspnet_client/load.aspx
eos

      # default value for the check response
      out = false

      # first test that we can get something
      contents = http_get_body "#{_get_entity_name}"
      _log_error "failing, unable to get a response" unless contents

      # check all paths for a non-error response
      known_webshell_paths.split("\n").each do |webshell_path|
        _log "Getting: #{webshell_path}"

        full_path = "#{_get_entity_name}#{webshell_path}"

        # get the body
        resp = http_request :get, full_path

        # make sure we got a response
        if resp.body.empty?
          _log_error "No response for #{full_path}! #{contents}"
          next
        end

        # check for a missing page
        unless resp.body =~ /The resource cannot be found/
          out = { url: full_path, contents: contents }
        end

      end

    out
    end
  end
end

end