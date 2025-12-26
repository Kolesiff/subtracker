import '../../data/models/subscription.dart';

/// Popular trial services with pre-filled data
/// Uses Unavatar.io for logos (free, no auth required)
class PopularTrials {
  static final List<Map<String, dynamic>> services = [
    // Entertainment - Streaming
    {
      'name': 'Netflix',
      'logo': 'https://unavatar.io/netflix.com',
      'defaultCost': 15.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 0, // No free trial currently
    },
    {
      'name': 'Spotify',
      'logo': 'https://unavatar.io/spotify.com',
      'defaultCost': 11.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 30,
    },
    {
      'name': 'Disney+',
      'logo': 'https://unavatar.io/disneyplus.com',
      'defaultCost': 13.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 7,
    },
    {
      'name': 'Max',
      'logo': 'https://unavatar.io/max.com',
      'defaultCost': 15.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 7,
    },
    {
      'name': 'YouTube Premium',
      'logo': 'https://unavatar.io/youtube.com',
      'defaultCost': 13.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 30,
    },
    {
      'name': 'Apple Music',
      'logo': 'https://unavatar.io/apple.com',
      'defaultCost': 10.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 30,
    },
    {
      'name': 'Amazon Prime',
      'logo': 'https://unavatar.io/amazon.com',
      'defaultCost': 14.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 30,
    },
    {
      'name': 'Hulu',
      'logo': 'https://unavatar.io/hulu.com',
      'defaultCost': 17.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 30,
    },
    {
      'name': 'Peacock',
      'logo': 'https://unavatar.io/peacocktv.com',
      'defaultCost': 7.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 7,
    },
    {
      'name': 'Paramount+',
      'logo': 'https://unavatar.io/paramountplus.com',
      'defaultCost': 11.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 7,
    },
    {
      'name': 'Crunchyroll',
      'logo': 'https://unavatar.io/crunchyroll.com',
      'defaultCost': 7.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 14,
    },
    {
      'name': 'Twitch',
      'logo': 'https://unavatar.io/twitch.tv',
      'defaultCost': 8.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 0,
    },
    {
      'name': 'Discord Nitro',
      'logo': 'https://unavatar.io/discord.com',
      'defaultCost': 9.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 7,
    },
    {
      'name': 'PlayStation Plus',
      'logo': 'https://unavatar.io/playstation.com',
      'defaultCost': 17.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 14,
    },
    {
      'name': 'Xbox Game Pass',
      'logo': 'https://unavatar.io/xbox.com',
      'defaultCost': 16.99,
      'category': SubscriptionCategory.entertainment,
      'trialDays': 14,
    },

    // Productivity
    {
      'name': 'Microsoft 365',
      'logo': 'https://unavatar.io/microsoft.com',
      'defaultCost': 9.99,
      'category': SubscriptionCategory.productivity,
      'trialDays': 30,
    },
    {
      'name': 'Notion',
      'logo': 'https://unavatar.io/notion.so',
      'defaultCost': 10.00,
      'category': SubscriptionCategory.productivity,
      'trialDays': 0, // Free tier available
    },
    {
      'name': 'Slack',
      'logo': 'https://unavatar.io/slack.com',
      'defaultCost': 8.75,
      'category': SubscriptionCategory.productivity,
      'trialDays': 0, // Free tier available
    },
    {
      'name': 'Zoom',
      'logo': 'https://unavatar.io/zoom.us',
      'defaultCost': 15.99,
      'category': SubscriptionCategory.productivity,
      'trialDays': 0, // Free tier available
    },
    {
      'name': 'Canva',
      'logo': 'https://unavatar.io/canva.com',
      'defaultCost': 12.99,
      'category': SubscriptionCategory.productivity,
      'trialDays': 30,
    },
    {
      'name': 'Evernote',
      'logo': 'https://unavatar.io/evernote.com',
      'defaultCost': 14.99,
      'category': SubscriptionCategory.productivity,
      'trialDays': 14,
    },
    {
      'name': 'Google One',
      'logo': 'https://unavatar.io/google.com',
      'defaultCost': 2.99,
      'category': SubscriptionCategory.productivity,
      'trialDays': 0,
    },
    {
      'name': 'Dropbox',
      'logo': 'https://unavatar.io/dropbox.com',
      'defaultCost': 11.99,
      'category': SubscriptionCategory.productivity,
      'trialDays': 30,
    },
    {
      'name': 'OneDrive',
      'logo': 'https://unavatar.io/onedrive.live.com',
      'defaultCost': 1.99,
      'category': SubscriptionCategory.productivity,
      'trialDays': 0,
    },
    {
      'name': '1Password',
      'logo': 'https://unavatar.io/1password.com',
      'defaultCost': 2.99,
      'category': SubscriptionCategory.productivity,
      'trialDays': 14,
    },
    {
      'name': 'NordVPN',
      'logo': 'https://unavatar.io/nordvpn.com',
      'defaultCost': 12.99,
      'category': SubscriptionCategory.productivity,
      'trialDays': 30,
    },
    {
      'name': 'ExpressVPN',
      'logo': 'https://unavatar.io/expressvpn.com',
      'defaultCost': 12.95,
      'category': SubscriptionCategory.productivity,
      'trialDays': 7,
    },

    // Health & Fitness
    {
      'name': 'Headspace',
      'logo': 'https://unavatar.io/headspace.com',
      'defaultCost': 12.99,
      'category': SubscriptionCategory.health,
      'trialDays': 7,
    },
    {
      'name': 'Calm',
      'logo': 'https://unavatar.io/calm.com',
      'defaultCost': 14.99,
      'category': SubscriptionCategory.health,
      'trialDays': 7,
    },
    {
      'name': 'Strava',
      'logo': 'https://unavatar.io/strava.com',
      'defaultCost': 11.99,
      'category': SubscriptionCategory.health,
      'trialDays': 30,
    },
    {
      'name': 'MyFitnessPal',
      'logo': 'https://unavatar.io/myfitnesspal.com',
      'defaultCost': 19.99,
      'category': SubscriptionCategory.health,
      'trialDays': 30,
    },
    {
      'name': 'Fitbit Premium',
      'logo': 'https://unavatar.io/fitbit.com',
      'defaultCost': 9.99,
      'category': SubscriptionCategory.health,
      'trialDays': 90,
    },

    // Education
    {
      'name': 'Duolingo Plus',
      'logo': 'https://unavatar.io/duolingo.com',
      'defaultCost': 12.99,
      'category': SubscriptionCategory.education,
      'trialDays': 14,
    },
    {
      'name': 'LinkedIn Premium',
      'logo': 'https://unavatar.io/linkedin.com',
      'defaultCost': 29.99,
      'category': SubscriptionCategory.education,
      'trialDays': 30,
    },
    {
      'name': 'Coursera',
      'logo': 'https://unavatar.io/coursera.org',
      'defaultCost': 59.00,
      'category': SubscriptionCategory.education,
      'trialDays': 7,
    },
    {
      'name': 'Skillshare',
      'logo': 'https://unavatar.io/skillshare.com',
      'defaultCost': 13.99,
      'category': SubscriptionCategory.education,
      'trialDays': 7,
    },
    {
      'name': 'MasterClass',
      'logo': 'https://unavatar.io/masterclass.com',
      'defaultCost': 15.00,
      'category': SubscriptionCategory.education,
      'trialDays': 0,
    },

    // Shopping & Food
    {
      'name': 'DoorDash',
      'logo': 'https://unavatar.io/doordash.com',
      'defaultCost': 9.99,
      'category': SubscriptionCategory.shopping,
      'trialDays': 30,
    },
    {
      'name': 'Uber Eats',
      'logo': 'https://unavatar.io/ubereats.com',
      'defaultCost': 9.99,
      'category': SubscriptionCategory.shopping,
      'trialDays': 30,
    },
    {
      'name': 'Instacart',
      'logo': 'https://unavatar.io/instacart.com',
      'defaultCost': 9.99,
      'category': SubscriptionCategory.shopping,
      'trialDays': 14,
    },
    {
      'name': 'Walmart+',
      'logo': 'https://unavatar.io/walmart.com',
      'defaultCost': 12.95,
      'category': SubscriptionCategory.shopping,
      'trialDays': 30,
    },

    // News & Reading
    {
      'name': 'Audible',
      'logo': 'https://unavatar.io/audible.com',
      'defaultCost': 14.95,
      'category': SubscriptionCategory.other,
      'trialDays': 30,
    },
    {
      'name': 'Kindle Unlimited',
      'logo': 'https://unavatar.io/kindle.amazon.com',
      'defaultCost': 11.99,
      'category': SubscriptionCategory.other,
      'trialDays': 30,
    },
    {
      'name': 'Medium',
      'logo': 'https://unavatar.io/medium.com',
      'defaultCost': 5.00,
      'category': SubscriptionCategory.other,
      'trialDays': 0,
    },
    {
      'name': 'The New York Times',
      'logo': 'https://unavatar.io/nytimes.com',
      'defaultCost': 4.00,
      'category': SubscriptionCategory.other,
      'trialDays': 30,
    },
    {
      'name': 'Wall Street Journal',
      'logo': 'https://unavatar.io/wsj.com',
      'defaultCost': 4.00,
      'category': SubscriptionCategory.other,
      'trialDays': 30,
    },
  ];

  /// Get services filtered by category
  static List<Map<String, dynamic>> getByCategory(SubscriptionCategory category) {
    return services.where((s) => s['category'] == category).toList();
  }

  /// Get services that have free trials
  static List<Map<String, dynamic>> getWithTrials() {
    return services.where((s) => (s['trialDays'] as int) > 0).toList();
  }
}
