package model

// Tag exported
type Tag struct {
	Name        string `json:"name" db:"name"`
	DisplayName string `json:"displayName" db:"display_name"`
}

// TagsAll example
func TagsAll() ([]Tag, error) {
	return tags, nil
}

var maxAds = 2
var tags = []Tag{
	{Name: "test", DisplayName: "Test"},
}
