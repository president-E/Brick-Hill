export interface User {
  id: number
  username: string
  description: string | null
  avatar_items: AvatarItems
  avatar_colors: AvatarColors
  bucks: number
  bits: number
  power: number
  created_at: string
  last_online: string
  theme: number
  is_verified_designer: boolean
}

export interface AvatarItems {
  hats: number[]
  face: number
  head: number
  tool: number
  face_asset?: number | null
  head_asset?: number | null
}

export interface AvatarColors {
  head: string
  torso: string
  left_arm: string
  right_arm: string
  left_leg: string
  right_leg: string
}

export interface Item {
  id: number
  creator_id: number
  name: string
  description: string | null
  type_id: number
  price_bucks: number | null
  price_bits: number | null
  is_public: boolean
  is_approved: boolean
  is_pending: boolean
  special: boolean
  special_edition: boolean
  special_q: number | null
  average_price: number | null
  thumbnail_url: string | null
  created_at: string
  updated_at: string
  creator?: User
  type?: ItemType
}

export interface ItemType {
  id: number
  name: string
  display_name: string
}

export interface Set {
  id: number
  creator_id: number
  name: string
  description: string | null
  visits: number
  playing: number
  max_players: number | null
  is_featured: boolean
  thumbnail_url: string | null
  created_at: string
  updated_at: string
  creator?: User
}

export interface Friend {
  id: number
  from_id: number
  to_id: number
  is_pending: boolean
  created_at: string
  from_user?: User
  to_user?: User
}

export interface Crate {
  id: number
  user_id: number
  item_id: number
  acquired_at: string
  item?: Item
}

export interface Trade {
  id: number
  sender_id: number
  receiver_id: number
  status: 'pending' | 'accepted' | 'declined' | 'cancelled'
  sender_items: number[]
  receiver_items: number[]
  created_at: string
  updated_at: string
  sender?: User
  receiver?: User
  sender_items_data?: Item[]
  receiver_items_data?: Item[]
}

export interface Message {
  id: number
  author_id: number
  recipient_id: number
  subject: string
  content: string
  is_read: boolean
  created_at: string
  author?: User
}

export interface ForumThread {
  id: number
  author_id: number
  title: string
  category_id: number
  is_locked: boolean
  is_pinned: boolean
  created_at: string
  updated_at: string
  author?: User
  posts_count?: number
}

export interface ForumPost {
  id: number
  thread_id: number
  author_id: number
  content: string
  created_at: string
  updated_at: string
  author?: User
}
