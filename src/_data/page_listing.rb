# frozen_string_literal: true

src_yaml = <<~LISTING
  sections:
    - name: What Is This?
      pages:
        - url: /about/this-site/
          title: A Very Important Disclaimer
          short_title: About This
        - url: /about/this-data/
          title: About This Data
          short_title: Data Collection
        - url: /about/downloading-data/
          title: Downloading the Data
          short_title: Data Downloads
        - url: /about/contributing/
          title: How to Contribute
          short_title: Contributing
        - url: /about/these-symbols/
          title: Symbols & Terminology
          short_title: Icons & Terms
        - url: /about/changes/
          title: What's Changed?
        - url: /about/whats-next/
          title: What's Next?
    - name: DOGE's Projects
      pages:
        - url: /projects/
          title: DOGE's Projects
          short_title: The Goals
        - url: /projects/dei/
          title: Targeting DEI
          short_title: DEI
        - url: /projects/anti-personnel/
          title: Attacking the Federal Workforce
          short_title: Anti-Personnel
        - url: /projects/deregulation/
          title: Regulatory Rollback
          short_title: Deregulation
        - url: /projects/impunity/
          title: Acting with Impunity
          short_title: Impunity
        - url: /projects/elimination/
          title: Total Elimination
          short_title: Elimination
        - url: /projects/viral-waste
          title: Fraud and Waste
          short_title: Fraud
        - url: /projects/spending-control/
          title: Seizing Control of Spending
          short_title: Spending Control
        - url: /projects/it-modernization/
          title: IT Modernization & AI
          short_title: IT/AI
        - url: /projects/immigration/
          title: Immigration Surveillance
          short_title: immigration
    - name: DOGE's Methods
      pages:
        - url: /projects/exec-orders/
          title: Executive Orders
          short_title: Exec Orders
        - url: /people/details
          title: The Devils in the Details
          short_title: Using Details
        - url: /people/wreckers
          title: Wrecking Crews
        - url: /people/agency-heads-cios/
          title: Agency Heads and CIOs
          short_title: Agency Heads
    - name: DOGE's Timeline
      pages:
        - url: /timeline/
          title: The DOGE Timeline
          short_title: Timeline
    - name: The People in DOGE
      pages:
        - url: /people/
          title: Who's in DOGE?
        - url: /people/paid-staff
          title: Who's Being Paid?
          short_title: Paid Staff
        - url: /people/aliases/
          title: Unmasked Aliases
    - name: Agencies Targeted
      pages:
        - url: /agencies/
          title: Agency Timeline
          short_title: The Agencies
        - url: /agencies/opm/
          title: Office of Personnel Management
          short_title: OPM
        - url: /agencies/gsa/
          title: General Services Administration
          short_title: GSA
        - url: /agencies/white-house/
          title: White House/DOGE
          short_title: DOGE
        - url: /agencies/nds/
          title: National Design Studio
          short_title: NDS
        - url: /agencies/usaid/
          title: US Agency for International Development
          short_title: USAID
        - url: /agencies/cfpb/
          title: Consumer Financial Protection Bureau
          short_title: CFPB
        - url: /agencies/agriculture/
          title: Department of Agriculture
          short_title: Agriculture
        - url: /agencies/commerce/
          title: Department of Commerce
          short_title: Commerce
        - url: /agencies/defense/
          title: Department of Defense
          short_title: Defense
        - url: /agencies/education/
          title: Department of Education
          short_title: Education
        - url: /agencies/energy/
          title: Department of Energy
          short_title: Energy
        - url: /agencies/homeland-security/
          title: Department of Homeland Security
          short_title: Homeland Security
        - url: /agencies/interior/
          title: Department of the Interior
          short_title: DOI
        - url: /agencies/justice/
          title: Department of Justice
          short_title: Justice
        - url: /agencies/labor/
          title: Department of Labor
          short_title: Labor
        - url: /agencies/transportation/
          title: Department of Transportation
          short_title: DOT
        - url: /agencies/epa/
          title: Environmental Protection Agency
          short_title: EPA
        - url: /agencies/health/
          title: Health and Human Services
          short_title: HHS
        - url: /agencies/housing/
          title: Housing and Urban Development
          short_title: HUD
        - url: /agencies/nasa/
          title: National Aeronautics and Space Administration
          short_title: NASA
        - url: /agencies/sba/
          title: Small Business Association
          short_title: SBA
        - url: /agencies/social-security/
          title: Social Security Administration
          short_title: Social Security
        - url: /agencies/state/
          title: State Department
          short_title: State
        - url: /agencies/treasury/
          title: The Treasury Department
          short_title: Treasury
        - url: /agencies/usps/
          title: US Postal Service
          short_title: USPS
        - url: /agencies/veterans/
          title: Veterans Administration
          short_title: VA
        - url: /agencies/nlrb/
          title: National Labor Relations Board
          short_title: NLRB
        - url: "/agencies/independent/"
          title: Independent Agencies
          short_title: Independents
    - name: Everything Pages
      pages:
        - url: /all/people/
          title: All the People
        - url: /all/events/
          title: All the Events
        - url: /all/positions/
          title: All the Staffing Moves
        - url: /all/systems/
          title: All the Systems
        - url: /all/sources/
          title: All the Source Citations
        - url: /all/questions/
          title: All Open Questions
LISTING

data = YAML.safe_load(src_yaml)

# Add in months
timeline_section = data['sections'].find { |section| section['name'] == "DOGE's Timeline" }

raise 'Unable to find the timeline section' if timeline_section.nil?

current = Date.parse('2025-01-20')
end_date = Date.today

while current <= end_date
  timeline_section['pages'].append({
                                     url: "/timeline/#{current.strftime('%Y/%m')}",
                                     title: current.strftime('%B %Y'),
                                     short_title: current.strftime('%b %Y')
                                   })

  current >>= 1 # next month
end

data
