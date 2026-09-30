import 'package:flutter/material.dart';

/// Category → help type → service. Every category has 4 help types and
/// every help type has 4 services.
class ServiceCategory {
  const ServiceCategory({
    required this.label,
    required this.description,
    required this.icon,
    required this.helpTypes,
    required this.detailsHint,
    this.isSoon = false,
  });

  final String label;
  final String description;
  final IconData icon;
  final List<HelpType> helpTypes;

  /// Example shown in the "Tell us a little more" field.
  final String detailsHint;
  final bool isSoon;
}

class HelpType {
  const HelpType(this.label, this.services);

  final String label;
  final List<String> services;
}

/// A partner the user can book with directly instead of via their LM.
enum Partner {
  bigBasket('BigBasket', 'https://www.bigbasket.com'),
  tata1mg('Tata 1mg', 'https://www.1mg.com'),
  makeMyTrip('MakeMyTrip', 'https://www.makemytrip.com'),
  uber('Uber', 'https://m.uber.com');

  const Partner(this.label, this.url);

  final String label;
  final String url;
}

/// Service categories shown on Home (first [homeTileCount] as tiles) and
/// on the All services screen.
abstract final class ServiceCatalog {
  static const homeTileCount = 6;

  /// Partner quick-book, keyed by service name.
  static const _partners = <String, Partner>{
    'Grocery pickup & restocking': Partner.bigBasket,
    'Weekly grocery run': Partner.bigBasket,
    'Fresh fruit & veg': Partner.bigBasket,
    'Household essentials': Partner.bigBasket,
    'Medicine delivery': Partner.tata1mg,
    'Prescription refills': Partner.tata1mg,
    'Lab test at home': Partner.tata1mg,
    'Flights': Partner.makeMyTrip,
    'Hotels & stays': Partner.makeMyTrip,
    'Airport transfers': Partner.uber,
  };

  static Partner? partnerFor(String service) => _partners[service];

  static const categories = <ServiceCategory>[
    ServiceCategory(
      label: 'Errands & Daily Tasks',
      description: 'Bills, banks, documents, government work',
      icon: Icons.fact_check_outlined,
      detailsHint: 'e.g. Renew car insurance before it lapses on the 15th',
      helpTypes: [
        HelpType('Pickups & Deliveries', [
          'Courier pickup/drop',
          'Grocery pickup & restocking',
          'Medicine pickup & refills',
          'Pet food & supplies pickup',
        ]),
        HelpType('Payments & Renewals', [
          'Utility bill payments',
          'Insurance renewals',
          'Vehicle registration renewal',
          'Property tax payment',
        ]),
        HelpType('Documents & Government', [
          'Aadhaar & PAN updates',
          'Passport appointments',
          'Certificates & attestation',
          'Bank KYC & paperwork',
        ]),
        HelpType('Shopping', [
          'Household essentials',
          'Gift shopping',
          'Returns & exchanges',
          'Specialty store runs',
        ]),
      ],
    ),
    ServiceCategory(
      label: 'Home Services',
      description: 'AC, plumbing, electrical, cleaning, repairs',
      icon: Icons.home_outlined,
      detailsHint: 'e.g. AC in the guest room is leaking onto the floor',
      helpTypes: [
        HelpType('Repairs & Maintenance', [
          'AC service & repair',
          'Plumbing',
          'Electrical work',
          'Carpentry',
        ]),
        HelpType('Cleaning', [
          'Deep home cleaning',
          'Sofa & carpet cleaning',
          'Kitchen & bathroom cleaning',
          'Water tank cleaning',
        ]),
        HelpType('Installations', [
          'Appliance installation',
          'Water purifier setup',
          'Curtains & fixtures',
          'TV wall mounting',
        ]),
        HelpType('Pest & Upkeep', [
          'Pest control',
          'Painting & touch-ups',
          'Waterproofing',
          'Garden & plant care',
        ]),
      ],
    ),
    ServiceCategory(
      label: 'Travel & Tourism',
      description: 'Flights, hotels, visas, transfers, itineraries',
      icon: Icons.place_outlined,
      detailsHint: 'e.g. Family of four to Goa over the long weekend',
      helpTypes: [
        HelpType('Bookings', [
          'Flights',
          'Hotels & stays',
          'Trains & buses',
          'Holiday packages',
        ]),
        HelpType('Visas & Documents', [
          'Visa applications',
          'Passport renewal',
          'Travel insurance',
          'Forex & travel cards',
        ]),
        HelpType('Local Transport', [
          'Airport transfers',
          'Outstation cabs',
          'Car with driver',
          'Self-drive rentals',
        ]),
        HelpType('On-Trip Support', [
          'Itinerary planning',
          'Local guide',
          'Emergency assistance',
          'Restaurant reservations',
        ]),
      ],
    ),
    ServiceCategory(
      label: 'Health & Medical',
      description: 'Doctor visits, pharmacy, labs, physio',
      icon: Icons.favorite_border,
      detailsHint: 'e.g. Dad needs a blood test at home, fasting, before 9am',
      helpTypes: [
        HelpType('Doctor & Consults', [
          'Doctor home visit',
          'Specialist appointment',
          'Teleconsultation',
          'Second opinion',
        ]),
        HelpType('Medicines', [
          'Prescription refills',
          'Medicine delivery',
          'Monthly medicine plan',
          'Medical equipment rental',
        ]),
        HelpType('Tests & Diagnostics', [
          'Lab test at home',
          'Health check-up package',
          'Scans & imaging booking',
          'Report collection',
        ]),
        HelpType('Therapy & Recovery', [
          'Physiotherapy at home',
          'Nursing care',
          'Post-surgery care',
          'Hospital admission help',
        ]),
      ],
    ),
    ServiceCategory(
      label: 'Senior Care',
      description: 'Check-ins, medicines, vitals, companionship',
      icon: Icons.people_outline,
      detailsHint: 'e.g. Mum lives alone and would like a call every evening',
      helpTypes: [
        HelpType('Daily Support', [
          'Daily check-in calls',
          'Medicine reminders',
          'Meal arrangements',
          'Groceries & essentials',
        ]),
        HelpType('Health Monitoring', [
          'Vitals tracking',
          'Doctor visit escort',
          'Health records upkeep',
          'Emergency response setup',
        ]),
        HelpType('Companionship', [
          'Companion visits',
          'Outings & walks',
          'Hobby & activity sessions',
          'Video calls with family',
        ]),
        HelpType('Home & Safety', [
          'Home safety check',
          'Grab bars & fixtures',
          'Caretaker hiring',
          'Bills & banking help',
        ]),
      ],
    ),
    ServiceCategory(
      label: 'Events & Management',
      description: 'Weddings, décor, catering, photography',
      icon: Icons.calendar_today_outlined,
      detailsHint: 'e.g. 7th birthday party at home for about 25 kids',
      helpTypes: [
        HelpType('Planning', [
          'Birthday party',
          'Anniversary',
          'Wedding planning',
          'Corporate event',
        ]),
        HelpType('Venue & Décor', [
          'Venue booking',
          'Décor & flowers',
          'Lighting & sound',
          'Tent & seating',
        ]),
        HelpType('Food & Catering', [
          'Catering',
          'Cakes & desserts',
          'Bartender service',
          'Home chef for the day',
        ]),
        HelpType('Entertainment & Media', [
          'Photography',
          'Videography',
          'DJ & music',
          'Kids entertainment',
        ]),
      ],
    ),
    ServiceCategory(
      label: 'Workforce Management',
      description: 'Maids, cooks, drivers, nannies, payroll',
      icon: Icons.work_outline,
      detailsHint: 'e.g. Cook for weekday dinners, vegetarian, family of four',
      helpTypes: [
        HelpType('Hire Help', ['Maid', 'Cook', 'Driver', 'Nanny']),
        HelpType('Replacement', [
          'Temporary replacement',
          'Permanent replacement',
          'Leave cover',
          'Trial staff',
        ]),
        HelpType('Verification', [
          'Police verification',
          'Background check',
          'Reference check',
          'Document check',
        ]),
        HelpType('Payroll & Records', [
          'Monthly payroll',
          'Attendance tracking',
          'Salary advances',
          'Staff agreements',
        ]),
      ],
    ),
    ServiceCategory(
      label: 'Digital & Tech Help',
      description: 'WiFi, CCTV, smart locks, device repair',
      icon: Icons.wifi,
      detailsHint: 'e.g. WiFi drops in the bedrooms at the back of the house',
      helpTypes: [
        HelpType('Internet & WiFi', [
          'New broadband connection',
          'WiFi range fix',
          'Router setup',
          'Slow internet troubleshooting',
        ]),
        HelpType('Security & Smart Home', [
          'CCTV installation',
          'Smart lock setup',
          'Video doorbell',
          'Smart home setup',
        ]),
        HelpType('Devices', [
          'Laptop & PC repair',
          'Phone repair',
          'Printer setup',
          'TV & DTH setup',
        ]),
        HelpType('Accounts & Apps', [
          'App & account setup',
          'Online payments help',
          'Data backup',
          'Parental controls',
        ]),
      ],
    ),
    ServiceCategory(
      label: 'Relocation Services',
      description: 'Packers, movers, handover, paperwork',
      icon: Icons.local_shipping_outlined,
      detailsHint: 'e.g. Moving a 2BHK from Koramangala to Whitefield',
      helpTypes: [
        HelpType('Moving', [
          'Packers & movers',
          'Vehicle transport',
          'Storage',
          'Pet relocation',
        ]),
        HelpType('House Hunting', [
          'Rental search',
          'Property visits',
          'Rent agreement',
          'Broker coordination',
        ]),
        HelpType('Handover & Setup', [
          'Move-out cleaning',
          'Deposit & handover',
          'Utility transfers',
          'Move-in setup',
        ]),
        HelpType('Paperwork', [
          'Address change',
          'Gas connection transfer',
          'School transfer',
          'Local registrations',
        ]),
      ],
    ),
    ServiceCategory(
      label: 'NutriFix',
      description: 'Groceries, food delivery, diet plans, meal prep',
      icon: Icons.shopping_bag_outlined,
      detailsHint: 'e.g. Low-sugar meal plan for my father, who is diabetic',
      isSoon: true,
      helpTypes: [
        HelpType('Groceries', [
          'Weekly grocery run',
          'Fresh fruit & veg',
          'Organic essentials',
          'Bulk monthly stock',
        ]),
        HelpType('Meals', [
          'Tiffin service',
          'Meal prep',
          'Party food orders',
          'Home chef',
        ]),
        HelpType('Diet & Nutrition', [
          'Dietitian consult',
          'Personal diet plan',
          'Diabetic meal plan',
          'Kids nutrition',
        ]),
        HelpType('Special Diets', [
          'Keto & low-carb',
          'Vegan meals',
          'Jain food',
          'Post-illness diet',
        ]),
      ],
    ),
    ServiceCategory(
      label: 'Fashion & Styling',
      description: 'Salon at home, tailoring, styling, gifting',
      icon: Icons.content_cut,
      detailsHint: 'e.g. Alter two kurtas and a blazer before next Friday',
      isSoon: true,
      helpTypes: [
        HelpType('Salon at Home', [
          'Haircut at home',
          'Facial & cleanup',
          'Manicure & pedicure',
          'Bridal makeup',
        ]),
        HelpType('Tailoring', [
          'Alterations',
          'Custom stitching',
          'Blouse stitching',
          'Dry cleaning & laundry',
        ]),
        HelpType('Styling', [
          'Wardrobe audit',
          'Occasion styling',
          'Personal shopper',
          'Closet organisation',
        ]),
        HelpType('Gifting', [
          'Curated gift hampers',
          'Corporate gifts',
          'Gift wrapping',
          'Same-day gift delivery',
        ]),
      ],
    ),
    ServiceCategory(
      label: 'Religious & Cultural',
      description: 'Pujas, priests, festivals, temple visits',
      icon: Icons.local_fire_department_outlined,
      detailsHint: 'e.g. Griha pravesh puja for our new flat next month',
      isSoon: true,
      helpTypes: [
        HelpType('Pujas', [
          'Griha pravesh',
          'Satyanarayan puja',
          'Ganesh puja',
          'Havan',
        ]),
        HelpType('Priests & Astrology', [
          'Book a pandit',
          'Online puja',
          'Astrology consult',
          'Muhurat timing',
        ]),
        HelpType('Festivals', [
          'Diwali preparations',
          'Festival décor',
          'Rangoli',
          'Festive sweets & food',
        ]),
        HelpType('Temple Visits', [
          'Darshan booking',
          'Pilgrimage tours',
          'Prasad delivery',
          'Special offerings',
        ]),
      ],
    ),
  ];
}
