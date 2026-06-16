import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export type Database = {
  public: {
    Tables: {
      users: {
        Row: {
          id: number
          username: string
          description: string | null
          avatar_items: JsonValue
          avatar_colors: JsonValue
          bucks: number
          bits: number
          power: number
          created_at: string
          last_online: string
          theme: number
          is_verified_designer: boolean
        }
        Insert: {
          id?: number
          username: string
          description?: string | null
          avatar_items?: JsonValue
          avatar_colors?: JsonValue
          bucks?: number
          bits?: number
          power?: number
          created_at?: string
          last_online?: string
          theme?: number
          is_verified_designer?: boolean
        }
        Update: {
          id?: number
          username?: string
          description?: string | null
          avatar_items?: JsonValue
          avatar_colors?: JsonValue
          bucks?: number
          bits?: number
          power?: number
          created_at?: string
          last_online?: string
          theme?: number
          is_verified_designer?: boolean
        }
      }
      items: {
        Row: {
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
        }
        Insert: {
          id?: number
          creator_id: number
          name: string
          description?: string | null
          type_id: number
          price_bucks?: number | null
          price_bits?: number | null
          is_public?: boolean
          is_approved?: boolean
          is_pending?: boolean
          special?: boolean
          special_edition?: boolean
          special_q?: number | null
          average_price?: number | null
          thumbnail_url?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: number
          creator_id?: number
          name?: string
          description?: string | null
          type_id?: number
          price_bucks?: number | null
          price_bits?: number | null
          is_public?: boolean
          is_approved?: boolean
          is_pending?: boolean
          special?: boolean
          special_edition?: boolean
          special_q?: number | null
          average_price?: number | null
          thumbnail_url?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      item_types: {
        Row: {
          id: number
          name: string
          display_name: string
        }
        Insert: {
          id?: number
          name: string
          display_name: string
        }
        Update: {
          id?: number
          name?: string
          display_name?: string
        }
      }
      sets: {
        Row: {
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
        }
        Insert: {
          id?: number
          creator_id: number
          name: string
          description?: string | null
          visits?: number
          playing?: number
          max_players?: number | null
          is_featured?: boolean
          thumbnail_url?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: number
          creator_id?: number
          name?: string
          description?: string | null
          visits?: number
          playing?: number
          max_players?: number | null
          is_featured?: boolean
          thumbnail_url?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      friends: {
        Row: {
          id: number
          from_id: number
          to_id: number
          is_pending: boolean
          created_at: string
        }
        Insert: {
          id?: number
          from_id: number
          to_id: number
          is_pending?: boolean
          created_at?: string
        }
        Update: {
          id?: number
          from_id?: number
          to_id?: number
          is_pending?: boolean
          created_at?: string
        }
      }
      crates: {
        Row: {
          id: number
          user_id: number
          item_id: number
          acquired_at: string
        }
        Insert: {
          id?: number
          user_id: number
          item_id: number
          acquired_at?: string
        }
        Update: {
          id?: number
          user_id?: number
          item_id?: number
          acquired_at?: string
        }
      }
      forum_threads: {
        Row: {
          id: number
          author_id: number
          title: string
          category_id: number
          is_locked: boolean
          is_pinned: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: number
          author_id: number
          title: string
          category_id: number
          is_locked?: boolean
          is_pinned?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: number
          author_id?: number
          title?: string
          category_id?: number
          is_locked?: boolean
          is_pinned?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      forum_posts: {
        Row: {
          id: number
          thread_id: number
          author_id: number
          content: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: number
          thread_id: number
          author_id: number
          content: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: number
          thread_id?: number
          author_id?: number
          content?: string
          created_at?: string
          updated_at?: string
        }
      }
      trades: {
        Row: {
          id: number
          sender_id: number
          receiver_id: number
          status: string
          sender_items: number[]
          receiver_items: number[]
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: number
          sender_id: number
          receiver_id: number
          status?: string
          sender_items?: number[]
          receiver_items?: number[]
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: number
          sender_id?: number
          receiver_id?: number
          status?: string
          sender_items?: number[]
          receiver_items?: number[]
          created_at?: string
          updated_at?: string
        }
      }
      messages: {
        Row: {
          id: number
          author_id: number
          recipient_id: number
          subject: string
          content: string
          is_read: boolean
          created_at: string
        }
        Insert: {
          id?: number
          author_id: number
          recipient_id: number
          subject: string
          content: string
          is_read?: boolean
          created_at?: string
        }
        Update: {
          id?: number
          author_id?: number
          recipient_id?: number
          subject?: string
          content?: string
          is_read?: boolean
          created_at?: string
        }
      }
    }
  }
}

type JsonValue = string | number | boolean | null | JsonValue[] | { [key: string]: JsonValue }
