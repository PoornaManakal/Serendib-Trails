import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  final List<TeamMember> teamMembers = [
    TeamMember(
        name: "Chamod Pankaja",
        role: "Main Backend Developer",
        imagePath: "lib/assets/images/Chamod.JPG"),
    TeamMember(
        name: "Kalana Shehara",
        role: "AR Developer",
        imagePath: "lib/assets/images/kalana.png"),
    TeamMember(
        name: "Poorna Manakal",
        role: "Backend Sub Developer",
        imagePath: "lib/assets/images/Poorna.jpg"),
    TeamMember(
        name: "S.Abiram",
        role: "Sub AR Developer",
        imagePath: "lib/assets/images/Abiram.jpg"),
    TeamMember(
        name: "Pamesha Devin",
        role: "Frontend Sub Developer",
        imagePath: "lib/assets/images/Devin.jpg"),
    TeamMember(
        name: "Kavindu Mendis",
        role: "Main Frontend Developer",
        imagePath: "lib/assets/images/Kavindu.jpg"),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: Color(0xFF0B5739),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("About",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "About Us",
                style: TextStyle(
                  color: Color(0xFF0B5739),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "At Serendib Trails, we aim to redefine your travel experience in Sri Lanka. "
                "Whether you're drawn to the serene beaches, lush hill-country, or rich cultural heritage, "
                "we create tailored itineraries that align with your interests and preferences.",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 10),
              Text(
                "Our mission is to help you discover the beauty of Sri Lanka seamlessly, "
                "with features like interactive maps, AR landmarks, transportation tips, and budget breakdowns – all in one place.",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 20),
              Text(
                "Why choose us?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B5739),
                ),
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint(
                      "Personalized Itineraries: Tailored trip plans based on your interests, trip duration, and budget."),
                  _buildBulletPoint(
                      "Interactive Maps: Navigate your route with ease using real-time location tracking."),
                  _buildBulletPoint(
                      "Augmented Reality (AR): Preview Sri Lanka's iconic landmarks like Sigiriya Rock and Temple of the Tooth in stunning AR."),
                  _buildBulletPoint(
                      "Budget Transparency: Plan your expenses with our detailed, day-by-day budget breakdown."),
                  _buildBulletPoint(
                      "Trusted Recommendations: Get reliable advice on attractions, accommodations, and transportation options."),
                ],
              ),
              SizedBox(height: 40),
              Center(
                child: Text(
                  "Team Serendib Trails",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,

                  
                    fontSize: 16,
                    color: Color(0xFF0B5739),

                  ),
                ),
              ),
              SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.85,
                ),
                itemCount: teamMembers.length,
                itemBuilder: (context, index) {
                  return TeamMemberWidget(teamMembers[index]);
                },
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B5739),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class TeamMember {
  final String name;
  final String role;
  final String imagePath;

  TeamMember({required this.name, required this.role, required this.imagePath});
}

class TeamMemberWidget extends StatelessWidget {
  final TeamMember teamMember;

  const TeamMemberWidget(this.teamMember);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              teamMember.imagePath,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                teamMember.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                teamMember.role,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 08,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
