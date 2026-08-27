import '../../domain/entities/ministry.dart';

/// Ordered list of the 4 ministry categories used for grid grouping. Also
/// mirrored in each [Ministry.category] value.
const List<String> ministryCategories = [
  'Liturgy & Worship',
  'Children & Youth',
  'Community & Outreach',
  'Operations & Governance',
];

/// Static, in-code (non-scraped) configuration for the Ministries tab.
/// Ported verbatim from the sibling reference app (`st_luke_frontend_app`,
/// `lib/features/ministries/data/static_ministries_data.dart`), treated as
/// already-approved parish-provided content per the approved BA plan.
const List<Ministry> staticMinistries = [
  // Liturgy & Worship
  Ministry(
    id: 'music',
    category: 'Liturgy & Worship',
    emoji: '🎵',
    name: 'Music Ministry',
    membersLine: '9 choirs',
    dayLine: 'Weekend Masses',
    tagline: 'Lifting hearts to God through song and worship',
    time: 'Sat 5:30pm · Sun 8am, 10am, 5:30pm',
    location: "St Luke's Church",
    open: 'All ages welcome',
    about:
        "St Luke's Music Ministry has grown remarkably since 2018, when it began with just two groups — Julia and Lisa's group and the St Luke's Chorale. Today we have 9 choirs serving our community.\n\n"
        "Our choirs include: St Luke's Chorale, Youth Choir, Children's Choir (4 years strong), CFCA Australia, Heart of Worship Choir, Divine Harmony, CFCI Choir, Feast Choir, and Jireh Youth Choir. Each choir brings its own character and enriches the liturgy across our four weekend Masses.",
    leaderName: 'Cristina Joya',
    leaderRole: 'Music Ministry Lead',
    leaderInitials: 'CJ',
    joinInfo:
        'Whether you sing, play an instrument, or want to support in any capacity, the Music Ministry welcomes you! With 9 choirs, there is a group for every style and age.\n\n'
        'Contact the parish office or speak to Cristina after Mass to find the right choir for you.',
    ctaLabel: 'Join Music Ministry',
    ctaEmail: 'marsdenpark@parracatholic.org?subject=Music Ministry Interest',
  ),
  Ministry(
    id: 'liturgical',
    category: 'Liturgy & Worship',
    emoji: '📖',
    name: 'Liturgical Ministry',
    membersLine: '42 active readers',
    dayLine: 'Weekend Masses',
    tagline: 'Proclaiming the Word of God with reverence and faith',
    time: 'Sat 5:30pm · Sun 8am, 10am, 5:30pm',
    location: "St Luke's Church",
    open: 'Adults — all parishioners',
    about:
        'The Liturgical Ministry (Reading Ministry) has grown to 42 active readers in 2025. Readers proclaim the Biblical readings during the Liturgy of the Word, making Mass spiritually enriching for the whole community.\n\n'
        'Earlier in 2025, the ministry ran two training workshops in June and August, led by Fr Gayan. These sessions reminded readers that their role is sacred — through their voices, God speaks to His people. Each proclamation is an act of faith, calling readers to prepare prayerfully and read with reverence.',
    leaderName: 'Aina Cruz',
    leaderRole: 'Liturgical Ministry Lead',
    leaderInitials: 'AC',
    joinInfo:
        'If you are a confident reader and feel called to proclaim the Word of God at Mass, this ministry is for you. Training and ongoing formation are provided.\n\n'
        'Contact the parish office to register your interest, and you will be invited to the next training session.',
    ctaLabel: 'Become a Reader',
    ctaEmail:
        'marsdenpark@parracatholic.org?subject=Liturgical Ministry Interest',
  ),
  Ministry(
    id: 'altar',
    category: 'Liturgy & Worship',
    emoji: '🕯️',
    name: 'Ministers of the Altar',
    membersLine: '7 ministers + juniors',
    dayLine: 'Weekend Masses',
    tagline: 'Serving at the altar with reverence and devotion',
    time: 'Sat 5:30pm · Sun 8am, 10am, 5:30pm',
    location: "St Luke's Church",
    open: 'Youth & adults',
    about:
        "St Luke's has a growing Ministers of the Altar ministry with 7 committed Ministers, the majority serving each weekend, alongside many Junior Servers including new members throughout 2025.\n\n"
        "Highlights include Ministers assisting at significant liturgical celebrations such as Easter and St Luke's Feast Day, practice sessions ahead of major celebrations, and experienced Ministers mentoring Junior Servers. A special milestone was moving into the new church building, which now provides a sacred space for vessels, vestments, and a tabernacle — allowing for prayers together after Mass.",
    leaderName: 'Dominic Gleeson',
    leaderRole: 'Ministers of the Altar Lead',
    leaderInitials: 'DG',
    joinInfo:
        'Young people and adults who feel called to serve at the altar are warmly invited. Training is provided for both Junior Servers and adult Ministers.\n\n'
        'Parents of children wishing to become Junior Servers, or adults interested in the ministry, should contact the parish office to register.',
    ctaLabel: 'Register as Altar Minister',
    ctaEmail:
        'marsdenpark@parracatholic.org?subject=Ministers of the Altar Interest',
  ),
  Ministry(
    id: 'emohc',
    category: 'Liturgy & Worship',
    emoji: '🫶',
    name: 'Extraordinary Ministers of Holy Communion',
    membersLine: 'Holy Communion',
    dayLine: '4 weekend Masses',
    tagline: "Bringing Christ's presence to our parish community",
    time: 'Sat 5:30pm · Sun 8am, 10am, 5:30pm',
    location: "St Luke's Church",
    open: 'Commissioned adults',
    about:
        "The Extraordinary Ministers of Holy Communion (EMoHC) ministry was formally led by Ana Conol from June 2025. When she began, the ministry had only a few volunteers — through Fr Gayan's encouragement, the team has since doubled in size.\n\n"
        'With the growth of Marsden Park and the move to the new church in October 2025, updated procedures were introduced including designated seating, revised Communion processes, and a continued emphasis on preparation and reverence. From December 2025, the ministry supports all four weekend Masses.',
    leaderName: 'Ana Conol',
    leaderRole: 'EMoHC Ministry Leader',
    leaderInitials: 'AC',
    joinInfo:
        'EMoHC ministers must be commissioned by the Diocese. If you feel called to this ministry of service, please speak to Fr Gayan or contact the parish office to begin the process.\n\n'
        'The ministry is open to practising Catholics in good standing who are willing to serve with dedication and reverence.',
    ctaLabel: 'Express Interest in EMoHC',
    ctaEmail: 'marsdenpark@parracatholic.org?subject=EMoHC Ministry Interest',
  ),
  // Children & Youth
  Ministry(
    id: 'youth',
    category: 'Children & Youth',
    emoji: '🧒',
    name: 'Luke-18',
    membersLine: 'Ages 11–21 · Up to 50',
    dayLine: '3rd Fri · 7pm',
    tagline: 'Faith, friendship and fun for teens & young adults aged 11–21',
    time: '6:30pm Mass + 7pm programme',
    location: "St Luke's Church & Hub",
    open: 'Ages 11–21',
    about:
        "What a big and blessed 2025 for St Luke's Youth Group — now with a shiny new name: Luke-18! We welcome teens aged 11–21 and gather on the third Friday of every month.\n\n"
        'Our numbers have continued to grow with up to 50 young people joining us. Youth nights follow a simple format: celebrating Mass together, games, fellowship, Prayer-Scripture reflection, and small group discussions. In 2025, several new Youth Leaders and Junior Leaders stepped up to serve for the very first time — and with God\'s grace, they have flourished.',
    leaderName: 'Lady Vinensig',
    leaderRole: 'Luke-18 Youth Ministry Lead',
    leaderInitials: 'LV',
    joinInfo:
        'All teens and young adults aged 11–21 are warmly welcome! Come along on the third Friday of the month — join us for the 6:30pm Mass and stay for the programme at 7pm.\n\n'
        'No registration needed — just show up! Parents can contact the parish office for more information.',
    ctaLabel: 'Join Luke-18',
    ctaEmail:
        'marsdenpark@parracatholic.org?subject=Luke-18 Youth Ministry Interest',
  ),
  Ministry(
    id: 'childrens',
    category: 'Children & Youth',
    emoji: '👦',
    name: "Children's Liturgy",
    membersLine: 'Kids during Mass',
    dayLine: 'Weekend Masses',
    tagline: 'Sharing the Gospel with our youngest parishioners',
    time: 'Sat 5:30pm · Sun 8am & 10am',
    location: "Music Room, St Luke's",
    open: 'Primary school-aged children',
    about:
        "The Children's Liturgy ministry team shares the Gospel with children during Mass in an age-appropriate setting. In 2025, they commenced their first Saturday Vigil class, expanding their reach to more families.\n\n"
        'The team found a wonderful solution in the Music Room, where whole-group discussions following the Gospel have been especially effective — reducing disruptions and creating more meaningful engagement. Children have shown growing understanding of the Gospel and how it applies to their everyday lives.',
    leaderName: 'Mandy Goswami',
    leaderRole: "Children's Liturgy Ministry Lead",
    leaderInitials: 'MG',
    joinInfo:
        "The Children's Liturgy team welcomes new volunteers who love working with children and sharing their faith. A Working with Children Check is required.\n\n"
        "Parents whose children wish to participate should simply bring them to any weekend Mass — the children's session runs during the Liturgy of the Word.",
    ctaLabel: 'Volunteer or Enrol Your Child',
    ctaEmail:
        "marsdenpark@parracatholic.org?subject=Children's Liturgy Interest",
  ),
  Ministry(
    id: 'sacramental',
    category: 'Children & Youth',
    emoji: '📿',
    name: 'Sacramental Process',
    membersLine: '250 candidates 2025',
    dayLine: 'Registrations open',
    tagline: 'Preparing children to receive the sacraments of initiation',
    time: 'Contact parish for 2026 dates',
    location: "St Luke's Catholic College",
    open: 'Baptised Catholic children 7+',
    about:
        "The Children's Sacramental Program uses the Parramatta Diocesan family-based and parish-supported programme to prepare children for Confirmation, Reconciliation, and Eucharist.\n\n"
        "In 2025, St Luke's celebrated: 103 Baptisms, 77 First Reconciliation, 70 First Eucharist, and Confirmation candidates. Sessions are facilitated by volunteers at St Luke's Catholic College over 3–4 weeks leading up to each sacrament.",
    leaderName: 'Julie Atkins',
    leaderRole: 'Sacramental Coordinator',
    leaderInitials: 'JA',
    joinInfo:
        'To enrol your child in the 2026 Sacramental Programme, contact the parish directly. Registrations are currently open for First Reconciliation (7+), First Eucharist (8+), and Confirmation (10+).\n\n'
        'For high school students (Year 7–12), email: sacraments@stlukesmarsdenpark.org.au',
    ctaLabel: 'Register for Sacraments',
    ctaEmail:
        'sacraments@stlukesmarsdenpark.org.au?subject=Sacramental Programme 2026',
  ),
  Ministry(
    id: 'sre',
    category: 'Children & Youth',
    emoji: '🏫',
    name: 'SRE Ministry',
    membersLine: '7 volunteers',
    dayLine: 'Weekly · Northbourne PS',
    tagline: 'Teaching children that they are loved by God',
    time: 'School hours (30 min sessions)',
    location: 'Northbourne Public School',
    open: 'Volunteer teachers welcome',
    about:
        'The Special Religious Education (SRE) Ministry currently has 7 volunteers who visit Northbourne Public School once a week to teach 30-minute Scripture lessons. In 2025, the programme expanded from K–Year 2 to now covering K–Year 5.\n\n'
        'Lessons use an engaging lesson book and teach children that they are loved for who they are and that God is always there for them. Volunteers use songs, videos, drama, crafts, and games, with special activities at Easter and Christmas. It has brought great joy to watch children grow in faith and look forward to Scripture class!',
    leaderName: 'Catherine Talam',
    leaderRole: 'SRE Parish Coordinator',
    leaderInitials: 'CT',
    joinInfo:
        'The SRE Ministry is always looking for enthusiastic volunteers willing to share their faith with primary school children. Training and resources are provided.\n\n'
        'Contact Catherine via the parish office to find out about joining this rewarding and impactful ministry.',
    ctaLabel: 'Volunteer for SRE',
    ctaEmail:
        'marsdenpark@parracatholic.org?subject=SRE Ministry Volunteer Interest',
  ),
  // Community & Outreach
  Ministry(
    id: 'welcome',
    category: 'Community & Outreach',
    emoji: '🤝',
    name: 'Welcome Ministry',
    membersLine: 'Greeting community',
    dayLine: 'Every Mass',
    tagline: 'Creating a sense of belonging for every parishioner',
    time: 'Before every Mass',
    location: "St Luke's Church entrance",
    open: 'All parishioners',
    about:
        "Jorge and Ana Pasaquian have been part of the Welcome Ministry since the very inception of St Luke's community — now 7 years of joyful service! They find immense joy in greeting parishioners with a warm smile and creating a sense of belonging.\n\n"
        'Over 7 years, the ministry has welcomed new and familiar faces, offering support and information to help everyone feel at home. Witnessing parishioners feel at ease during Mass, thanks to a warm welcome, is truly heartwarming to the team.',
    leaderName: 'Jorge & Ana Pasaquian',
    leaderRole: 'Welcome Ministry Leads',
    leaderInitials: 'JP',
    joinInfo:
        'If you have a welcoming heart and love meeting people, this ministry is a wonderful way to serve. Welcome ministers greet parishioners before each Mass.\n\n'
        "Contact the parish office to express your interest in joining this founding ministry of St Luke's.",
    ctaLabel: 'Join Welcome Ministry',
    ctaEmail: 'marsdenpark@parracatholic.org?subject=Welcome Ministry Interest',
  ),
  Ministry(
    id: 'hospitality',
    category: 'Community & Outreach',
    emoji: '☕',
    name: 'Hospitality Team',
    membersLine: 'Morning teas & events',
    dayLine: 'Parish events',
    tagline: 'Fostering fellowship, warmth and community connection',
    time: 'After selected Masses & events',
    location: "St Luke's Parish",
    open: 'All parishioners',
    about:
        'The Hospitality Team fosters a welcoming, caring and inclusive environment — helping everyone feel at home. In 2025, five new members joined in March, expanding the team\'s ability to serve.\n\n'
        "Throughout 2025, the team delivered 8 morning teas, 2 International Food Days, and supported the Dinner Dance. Key highlights included welcoming Fr Gayan at his Installation, hosting a Ministry Recruitment Drive morning tea, celebrating the Founding Anniversary, Pentecost, St Luke's Feast Day, and the historic first Mass in the new church building.",
    leaderName: 'Aleta Dela Cruz',
    leaderRole: 'Hospitality Team Lead',
    leaderInitials: 'AD',
    joinInfo:
        'The Hospitality Team welcomes anyone with a generous spirit and a love of community. Whether you can help set up, bring food to share, or assist on the day of events — there is a place for you.\n\n'
        'Contact the parish office to join this warm and joyful team.',
    ctaLabel: 'Join Hospitality Team',
    ctaEmail: 'marsdenpark@parracatholic.org?subject=Hospitality Team Interest',
  ),
  Ministry(
    id: 'fundraising',
    category: 'Community & Outreach',
    emoji: '🍽️',
    name: 'Fundraising Team',
    membersLine: '\$38k raised in 2025',
    dayLine: 'Monthly events',
    tagline: 'Injecting FUN into FUNDRAISING for our parish community',
    time: 'Various — see parish calendar',
    location: "St Luke's Parish & community",
    open: 'All parishioners & volunteers',
    about:
        "The Fundraising Team's joyful mission: inject FUN into FUNDRAISING by creating initiatives where everyone can support the Parish while enjoying something special in return. In 2025, the team raised over \$38,000 toward Stage 2 of the church building and operational costs.\n\n"
        "Highlights: 12 weekend food stalls, the Annual Dinner Dance (with free childminding!), and the Christmas Carols & Raffle Draw. Fun facts: 1,026 brownies, 353 empanadas, 298 chiffon cakes, 146 ube cupcakes, and 134 chicken biryanis were enjoyed! Over \$7,000 in event sponsorships was secured from generous local businesses.",
    leaderName: 'Aleta Dela Cruz',
    leaderRole: 'Fundraising Team Lead',
    leaderInitials: 'AD',
    joinInfo:
        'The Fundraising Team welcomes bakers, cooks, event helpers, and anyone with ideas and energy! Six new members joined at the March 2025 Volunteer Drive.\n\n'
        'Contact the parish office or come to the next Volunteer Drive to get involved in this creative and community-building team.',
    ctaLabel: 'Join Fundraising Team',
    ctaEmail: 'marsdenpark@parracatholic.org?subject=Fundraising Team Interest',
  ),
  Ministry(
    id: 'scripture',
    category: 'Community & Outreach',
    emoji: '✝️',
    name: 'Walking with Christ',
    membersLine: 'Walking with Christ',
    dayLine: 'Fortnightly Thu 7pm',
    tagline: 'Exploring Scripture together in community',
    time: '7:00pm',
    location: 'Parish Office',
    open: 'All parishioners',
    about:
        "Walking with Christ is St Luke's Scripture study group, meeting fortnightly on Thursday evenings at the parish office. The group explores the Sunday readings and broader biblical themes in a welcoming, discussion-based setting.\n\n"
        "Whether you're new to Scripture or have been reading the Bible for years, this group is a wonderful way to deepen your faith and connect with fellow parishioners.",
    leaderName: 'Fr Gayan Thamel',
    leaderRole: 'Parish Priest · Scripture Guide',
    leaderInitials: 'GT',
    joinInfo:
        'Simply turn up on a Thursday evening at 7pm at the parish office — no prior experience with Scripture study is needed, just an open heart and a curious mind.\n\n'
        'Contact the parish office to confirm the next session date, as the group meets fortnightly.',
    ctaLabel: 'Join Scripture Group',
    ctaEmail: 'marsdenpark@parracatholic.org?subject=Scripture Group Interest',
  ),
  // Operations & Governance
  Ministry(
    id: 'finance',
    category: 'Operations & Governance',
    emoji: '💰',
    name: 'Finance Committee',
    membersLine: 'Formed March 2025',
    dayLine: 'Monthly meetings',
    tagline: "Stewarding our parish's resources for God's mission",
    time: 'Contact parish for schedule',
    location: 'Parish Office',
    open: 'Appointed members',
    about:
        'The Parish Finance Committee was formed in March 2025 with Arvin Joya (Chair), Sumreen Munir (Secretary), Jilska Fernando and Glenfor Brewty (appointed members), and Fr Gayan Thamel and Ged Oblea (ex-officio). The committee meets monthly.\n\n'
        "In 2025, the committee successfully capped the parish's capital contribution for Stage 1 at \$500K (against a \$1.4M construction cost), created the inaugural annual budget, launched the Building Pledge Campaign (exceeding target by 40%), and achieved a 45% increase in weekend collections within three weeks of implementation.",
    leaderName: 'Arvin Joya',
    leaderRole: 'Finance Committee · Chair',
    leaderInitials: 'AJ',
    joinInfo:
        "The Finance Committee is an appointed body. If you have skills in finance, accounting, or strategic planning and feel called to support the parish's stewardship, please express your interest to Fr Gayan or the parish office.",
    ctaLabel: 'Express Interest',
    ctaEmail:
        'marsdenpark@parracatholic.org?subject=Finance Committee Interest',
  ),
  Ministry(
    id: 'ict',
    category: 'Operations & Governance',
    emoji: '💻',
    name: 'ICT Committee',
    membersLine: '6 volunteers',
    dayLine: 'AV & tech support',
    tagline: 'Using technology to enhance worship and community connection',
    time: 'Weekends & events',
    location: "St Luke's Church",
    open: 'Tech-skilled volunteers',
    about:
        "The ICT Committee was officially formed by Fr Gayan in June 2025, bringing together 6 volunteers to support the parish's growing technological needs. The team designed all audio-visual and networking requirements for the new parish building, working closely with the builder to finalise technical plans.\n\n"
        'Key achievements include researching and sourcing hardware for long-term ICT needs, setting up and testing all AV and network systems for the new church, and establishing video-streaming capability to overflow areas using NDI and video transmission technologies — so every parishioner can actively participate in the liturgy.',
    leaderName: 'Malinda Fernando',
    leaderRole: 'ICT Committee · Chair',
    leaderInitials: 'MF',
    joinInfo:
        'If you have skills in audio-visual technology, IT, networking, or video production and want to use them in service of the parish, the ICT Committee would love to hear from you.\n\n'
        'Contact the parish office to express your interest in joining this vital and growing ministry.',
    ctaLabel: 'Join ICT Committee',
    ctaEmail: 'marsdenpark@parracatholic.org?subject=ICT Committee Interest',
  ),
  Ministry(
    id: 'logistics',
    category: 'Operations & Governance',
    emoji: '🪑',
    name: 'Logistics Team',
    membersLine: 'Setup & events',
    dayLine: 'Every Saturday',
    tagline: 'Making every Mass and event possible through faithful service',
    time: 'Saturday mornings & as needed',
    location: "St Luke's Church & grounds",
    open: 'All volunteers welcome',
    about:
        "The Logistics Team has faithfully served St Luke's from 2018 to present, led by James Irundayaraj. Starting with 100 chairs in the Hub, the team grew into a vital ministry supported by a dedicated WhatsApp group of volunteers.\n\n"
        "Every Saturday, the team prepares the church for weekend Masses — setting up the altar, chairs, welcome tables, and cleaning, rain or shine. They also support major events including Easter, Christmas, Carols, and St Luke's Feast Day, often managing hundreds of chairs and designing event setups. Volunteers are now needed to maintain the new church and continue supporting parish activities.",
    leaderName: 'James Irundayaraj',
    leaderRole: 'Logistics Team Lead',
    leaderInitials: 'JI',
    joinInfo:
        'The Logistics Team always needs willing hands! Whether you can help set up on Saturday mornings or assist at special events, your contribution makes a direct difference to every Mass.\n\n'
        'Contact the parish office or speak to James after Mass to get involved.',
    ctaLabel: 'Join Logistics Team',
    ctaEmail: 'marsdenpark@parracatholic.org?subject=Logistics Team Interest',
  ),
  Ministry(
    id: 'maintenance',
    category: 'Operations & Governance',
    emoji: '🔧',
    name: 'Maintenance Ministry',
    membersLine: 'Building & grounds',
    dayLine: 'Ongoing',
    tagline: 'Caring for our parish building and grounds',
    time: 'Flexible',
    location: "St Luke's Church & grounds",
    open: 'Handy volunteers welcome',
    about:
        'The Maintenance Ministry had a busy 2025, beginning with inspecting and accepting the new church temporary building from the builder, then establishing the plants, gardens, watering and irrigation system.\n\n'
        'The team is also managing the construction of a new storage shed next to the church — which will help locate everyday equipment needed for church functions in one convenient location. Ongoing defect rectification and repairs throughout the life of the building are also managed by this dedicated team.',
    leaderName: 'Patrick Bilan',
    leaderRole: 'Maintenance Ministry Lead',
    leaderInitials: 'PB',
    joinInfo:
        'If you are handy with tools, gardening, or general building maintenance and want to contribute your skills to the parish, the Maintenance Ministry would welcome your help.\n\n'
        'Contact the parish office to get involved in keeping our parish home in great shape.',
    ctaLabel: 'Join Maintenance Ministry',
    ctaEmail:
        'marsdenpark@parracatholic.org?subject=Maintenance Ministry Interest',
  ),
];
