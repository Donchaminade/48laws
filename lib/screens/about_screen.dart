import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeInAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          color: const Color.fromARGB(255, 243, 243, 245),
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              color: Colors.black54,
              offset: Offset(2, 2),
              blurRadius: 4,
            )
          ],
        ),
      ),
    );
  }

  Widget _bodyText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
      textAlign: TextAlign.justify,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        backgroundColor: const Color.fromARGB(255, 4, 2, 145),
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Color.fromARGB(71, 4, 1, 199)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image / Illustration
                // Center(
                //   child: Container(
                //     margin: const EdgeInsets.only(bottom: 30),
                //     width: 150,
                //     height: 150,
                //     decoration: BoxDecoration(
                //       boxShadow: [
                //         BoxShadow(
                //           color: const Color.fromARGB(255, 4, 1, 145).withOpacity(0.6),
                //           blurRadius: 20,
                //           spreadRadius: 2,
                //           offset: const Offset(0, 0),
                //         ),
                //       ],
                //       shape: BoxShape.circle,
                //       image: const DecorationImage(
                //         image: NetworkImage(
                //             'https://i.ytimg.com/vi/0j7lCSUPl3s/maxresdefault.jpg'),
                //         fit: BoxFit.cover,
                //       ),
                //     ),
                //   ),
                // ),

                Container(
  width: double.infinity,
  child: Image.network(
    'https://i.ytimg.com/vi/0j7lCSUPl3s/maxresdefault.jpg',
    fit: BoxFit.cover,
  ),
),
                _sectionTitle('ABOUT THE BOOK'),
_bodyText(
  'The 48 Laws of Power is a bestselling book written by Robert Greene and Joost Elffers in 1998. Drawing inspiration from over 3,000 years of history and figures such as Niccolò Machiavelli, Sun Tzu, and Talleyrand, the book presents 48 timeless laws that reveal how to gain, maintain, and protect power in all areas of life. Each law is illustrated with historical examples and practical advice.'
  '\n\nSome notable laws include:'
  '\n1. Never outshine the master – Always make your superiors feel superior.'
  '\n2. Conceal your intentions – Mystery is a powerful weapon.'
  '\n3. Say less than necessary – Silence can command respect.'
  '\n4. Protect your reputation – It is the cornerstone of power.'
  '\n5. Court attention at all costs – Invisibility equals weakness.'
  '\n6. Crush your enemy totally – Leave no room for retaliation.'
  '\n7. Be unpredictable – It destabilizes and disarms opponents.'
  '\n8. Master the art of timing – Patience is power.'
  '\n\nThe final law encourages adaptability: "Assume the formlessness of water" – adjust to circumstances without losing your essence.'
  '\n\nThis book fascinates because it doesn’t judge power – it analyzes it. Some readers see it as a ruthless playbook, others as a realistic guide to navigating a competitive world. Either way, it never leaves the reader indifferent.'
),
_sectionTitle('VERSION FRANÇAISE'),
_bodyText(
  'Les 48 lois du pouvoir est un livre best-seller écrit par Robert Greene et Joost Elffers en 1998. S’appuyant sur plus de 3 000 ans d’histoire et des figures comme Machiavel, Sun Tzu ou Talleyrand, ce livre présente 48 lois intemporelles qui expliquent comment acquérir, conserver et protéger le pouvoir dans tous les domaines de la vie. Chaque loi est illustrée par des exemples historiques et des conseils pratiques.'
  '\n\nVoici quelques lois marquantes :'
  '\n1. Ne surpassez jamais le maître – Faites toujours en sorte que vos supérieurs se sentent supérieurs.'
  '\n2. Dissimulez vos intentions – Le mystère est une arme puissante.'
  '\n3. Dites-en moins que nécessaire – Le silence impose le respect.'
  '\n4. Protégez votre réputation – Elle est la pierre angulaire du pouvoir.'
  '\n5. Attirez l’attention à tout prix – L’invisibilité équivaut à la faiblesse.'
  '\n6. Écrasez totalement votre ennemi – Ne laissez aucune possibilité de revanche.'
  '\n7. Soyez imprévisible – Cela déstabilise et désarme vos adversaires.'
  '\n8. Maîtrisez l’art du timing – La patience est une forme de puissance.'
  '\n\nLa dernière loi conseille de "prendre la forme de l’eau" – c’est-à-dire de rester flexible et adaptable sans jamais perdre votre essence.'
  '\n\nCe livre fascine car il n’émet pas de jugement sur le pouvoir, il l’analyse simplement. Certains le considèrent comme un manuel cynique, d’autres comme un guide réaliste pour évoluer dans un monde compétitif. Dans tous les cas, il ne laisse personne indifférent.'
),


                const SizedBox(height: 20),

_sectionTitle('ABOUT THE AUTHOR'),
_bodyText(
  'Robert Greene\n'
  'Born on May 14, 1959, in Los Angeles, Robert Greene is an American author of Jewish descent, renowned for his books on strategy, power, seduction, and mastery. He holds a degree in philosophy and worked in various fields before becoming a writer.\n\n'
  'He is best known for his international bestsellers that analyze power dynamics and human relationships through history and psychology, including:\n\n'
  '- The 48 Laws of Power, published in 1998, a widely influential manual on acquiring and maintaining power.\n'
  '- The Art of Seduction, exploring the mechanisms of attraction and influence.\n'
  '- The 33 Strategies of War, a guide on military tactics applied to personal and professional conflicts.\n'
  '- Laws of Power 50, co-written with rapper 50 Cent, combining power strategies and hip-hop culture.\n'
  '- Mastery, a book focused on skill mastery and personal excellence.\n\n'
  'Greene’s works draw on historical, literary, and philosophical examples, blending insights from Machiavelli, Sun Tzu, Talleyrand, and other famous thinkers. His analytical and non-moral approach to power generates both admiration and controversy.'
),

_sectionTitle('version FRANÇAISE'),
_bodyText(
  'Robert Greene\n'
  'Né le 14 mai 1959 à Los Angeles, Robert Greene est un auteur américain d’origine juive, célèbre pour ses ouvrages sur la stratégie, le pouvoir, la séduction et la maîtrise de soi. Diplômé en philosophie, il a travaillé dans divers domaines avant de devenir écrivain.\n\n'
  'Il est surtout connu pour ses livres best-sellers internationaux qui analysent les dynamiques du pouvoir et des relations humaines à travers l’histoire et la psychologie, notamment :\n\n'
  '- Les 48 lois du pouvoir (The 48 Laws of Power), publié en 1998, un manuel stratégique largement influent sur la manière d’acquérir et de conserver le pouvoir.\n'
  '- L’art de la séduction (The Art of Seduction), explorant les mécanismes de l’attraction et de l’influence.\n'
  '- Les 33 stratégies de la guerre (The 33 Strategies of War), un guide sur les tactiques militaires appliquées aux conflits personnels et professionnels.\n'
  '- Laws of Power 50, écrit en collaboration avec le rappeur 50 Cent, combinant stratégies de pouvoir et culture hip-hop.\n'
  '- Mastery, un ouvrage dédié à la maîtrise des compétences et à l’excellence personnelle.\n\n'
  'Les livres de Greene s’appuient sur des exemples historiques, littéraires et philosophiques, mêlant Machiavel, Sun Tzu, Talleyrand et d’autres penseurs célèbres. Son approche analytique et non morale du pouvoir suscite autant d’admiration que de controverse.'
),


                const SizedBox(height: 20),


Container(
  width: double.infinity,
  child: Image.network(
    'https://donchaminade.vercel.app/assets/imgs/profil.png',
    fit: BoxFit.cover,
  ),
),

_sectionTitle('À PROPOS DE L’APPLICATION'),
_bodyText(
  'Cette application rend hommage à l\'œuvre de Robert Greene, conçue pour rendre les 48 lois du pouvoir accessibles et captivantes pour les francophones. Elle propose :\n\n'
  '- Une interface intuitive pour naviguer facilement à travers les lois.\n'
  '- Une fonction de recherche pour trouver rapidement une loi ou un sujet précis.\n'
  '- Un système de favoris pour enregistrer ses lois préférées.\n'
  '- Une fonctionnalité de prise de notes pour annoter ses réflexions personnelles sur chaque loi.\n'
  '- Un mode sombre pour une lecture confortable la nuit.\n\n'
  'L’application vise à offrir une manière moderne et interactive d’explorer la sagesse intemporelle des 48 lois du pouvoir, en encourageant les utilisateurs à réfléchir à leurs propres expériences et à appliquer ces principes dans leur vie.'
  '\n\n'
  'Cette application est développée par ADJOLOU Dondah Chaminade :'
  ' \nX    (https://x.com/donchaminade)'
  '\nLinkedIn (https://www.linkedin.com/in/chaminadeadjolou/)'
  '\nPortfolio : https://donchaminade.vercel.app'
),

// Ensuite, pour afficher une image en ligne qui prend toute la largeur :


              ],
            ),
          ),
        ),
      ),
    );
  }
}
